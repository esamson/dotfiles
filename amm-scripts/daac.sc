/**
  * Download at all costs.
  *
  * requires http://ammonite.io/
  */
import java.awt.Desktop
import java.net.HttpURLConnection.HTTP_PARTIAL
import java.net.{HttpCookie, URI}
import java.nio.file.StandardCopyOption.REPLACE_EXISTING
import java.nio.file.StandardOpenOption._
import java.nio.file.{Files, Path, Paths}
import java.util.concurrent.TimeUnit._
import java.util.concurrent.atomic.AtomicLong
import java.util.concurrent.{Executors, TimeUnit}

import scalaj.http._

import scala.concurrent._
import scala.concurrent.duration.Duration
import scala.math.BigDecimal.RoundingMode
import scala.math.{min, pow}
import scala.util.{Failure, Random, Success, Try}

case class DownloadSpec(url: String, headers: Map[String, IndexedSeq[String]]) {

  def pretty(values: Seq[String]): String = values.length match {
    case 0 => "[]"
    case 1 => values.head
    case _ => values.mkString("[\n    ", "\n    ", "  \n]")
  }

  def prettyPrint(headers: Map[String, IndexedSeq[String]]): String = {
    headers
      .map({ case (header, values) => s"$header = ${pretty(values)}" })
      .mkString("\n  ")
  }

  override def toString: String =
    s"""DownloadSpec($url
       |  ${prettyPrint(headers)}
       |)""".stripMargin
}

case class Split(
    fileName: String,
    start: Long,
    end: Long,
    req: HttpRequest
)

@scala.annotation.tailrec
def inspect(url: String, cookies: Seq[HttpCookie]): Option[DownloadSpec] = {
  val req = Http(url)
    .header("Range", s"bytes=0-0")
    .cookies(cookies)
  val probe = req.exec((_, headers, inputStream) => {
    // ignore body
    inputStream.close()
    DownloadSpec(url, headers)
  })

  probe match {
    case r if r.isRedirect           => inspect(r.location.get, cookies)
    case s if s.code == HTTP_PARTIAL => Option(s.body)
    case x =>
      println(s"Server returned ${x.code}; ${x.body}")
      None
  }
}

val MaxBackoffMs = 10000
val BackoffSlotMs = 100
val MaxBackoffSlots = Stream
  .from(1)
  .filter(n => (pow(2, n).toInt - 1) * BackoffSlotMs > MaxBackoffMs)
  .head
val cacheDir = Paths.get(sys.props("user.home"), "Downloads", ".daac")

def cleanUpCacheDir() = {
  val maxAge = TimeUnit.DAYS.toMillis(7)
  val cutOff = System.currentTimeMillis() - maxAge

  if (Files.exists(cacheDir)) {
    for {
      cacheFile <- cacheDir.toFile.listFiles()
      if cacheFile.lastModified() < cutOff
    } {
      cacheFile.delete()
    }

    if (cacheDir.toFile.listFiles().isEmpty) {
      Files.delete(cacheDir)
    }
  }
}

@scala.annotation.tailrec
def retry[T](backoffSlots: Int = 0)(f: => T): T = {
  Try {
    if (backoffSlots > 0) {
      Thread.sleep(
        min(
          MaxBackoffMs,
          Random.nextInt(
            pow(2, min(MaxBackoffSlots, backoffSlots)).toInt - 1
          ) * BackoffSlotMs
        )
      )
    }

    f
  } match {
    case Success(result) => result
    case Failure(ex) =>
      ex match {
        case ex: AssertionError => throw ex
        case cause =>
          if ((backoffSlots + 1) % 10 == 0) {
            println(s"Try ${backoffSlots + 1} failed. $cause")
          }
          retry(backoffSlots + 1)(f)
      }
  }
}

def download(split: Split, progressAccumulator: AtomicLong)(
    implicit ec: ExecutionContext): Future[Path] = Future {
  retry() {
    if (!Files.exists(cacheDir)) {
      Files.createDirectories(cacheDir)
    }
    val cacheFile =
      cacheDir.resolve(s"${split.fileName}.${split.start}-${split.end}")

    if (!Files.exists(cacheFile) ||
        cacheFile.toFile.length() != split.end - split.start) {
      val response = blocking {
        split.req.asBytes
      }

      if (response.code != HTTP_PARTIAL) {
        throw new AssertionError(
          s"Expected $HTTP_PARTIAL but got ${response.code}")
      }

      val contentLength = response
        .header("Content-Length")
        .map(_.toInt)
        .getOrElse(throw new AssertionError("No Content-Length"))

      require(
        contentLength == response.body.length,
        s"Expected $contentLength bytes but downloaded ${response.body.length}.")

      progressAccumulator.addAndGet(response.body.length)

      Files.write(cacheFile, response.body)
    }

    cacheFile
  }
}

val SplitSize = 1L << 17
val ProgressInterval = SECONDS.toMillis(10)
val SmoothingFactor = BigDecimal("0.05")

def cookies(url: String): Seq[HttpCookie] = {
  val uri = new URI(url)
  if (uri.getHost == "download.oracle.com") {
    Seq(new HttpCookie("oraclelicense", "accept-securebackup-cookie"))
  } else {
    Nil
  }
}

@main
def main(urls: String*) = {
  for (url <- urls) {
    downloadUrl(url)
  }
}

def downloadUrl(url: String) = {
  val result = for {
    spec <- inspect(url, cookies(url))
    contentRange <- spec.headers.get("Content-Range").flatMap(_.headOption)
    contentSize <- contentRange.split('/').last match {
      case "*"  => None
      case size => Some(size.toLong)
    }
  } yield {
    println(s"Downloading: $spec")
    val fileName = spec.headers
      .get("Content-Disposition")
      .flatMap(_.headOption)
      .flatMap { contentDisposition =>
        contentDisposition
          .split(""";\s*""")
          .find(_.startsWith("filename"))
          .map(_.split('=').last.replaceAll("^\"|\"$", ""))
      }
      .getOrElse(new URI(spec.url).getPath.split('/').last)
    val destFile = Paths.get(sys.props("user.dir")).resolve(fileName)

    if (Files.exists(destFile) && Files.size(destFile) == contentSize) {
      println(s"Already downloaded on ${Files.getLastModifiedTime(destFile)}")
      destFile
    } else {
      val request = Http(spec.url)

      val splits = {
        val last = contentSize - 1
        for {
          i <- 0L until contentSize by SplitSize
        } yield {
          val start = i
          val end = {
            val e = i + SplitSize - 1
            if (e > last) last else e
          }
          Split(fileName,
                start,
                end,
                request.header("Range", s"bytes=$start-$end"))
        }
      }

      val threadPool = Executors.newFixedThreadPool(100, (r: Runnable) => {
        val thread = new Thread(r)
        thread.setDaemon(true)
        thread.setPriority(Thread.MIN_PRIORITY)
        thread
      })
      implicit val executionContext = ExecutionContext.fromExecutor(threadPool)

      val progressAccumulator = new AtomicLong()
      val startTime = System.nanoTime()
      val downloads = splits.map { request =>
        download(request, progressAccumulator)
      }

      def prettyPrint(nanos: Long) = nanos match {
        case ns if NANOSECONDS.toMicros(ns) <= 1 =>
          s"$ns nanosecond${if (ns == 1) "" else "s"}"
        case us if NANOSECONDS.toMillis(us) <= 1 =>
          s"${NANOSECONDS.toMicros(us)} microseconds"
        case ms if NANOSECONDS.toSeconds(ms) <= 1 =>
          s"${NANOSECONDS.toMillis(ms)} milliseconds"
        case s if NANOSECONDS.toMinutes(s) <= 1 =>
          s"${NANOSECONDS.toSeconds(s)} seconds"
        case m if NANOSECONDS.toHours(m) <= 1 =>
          val minutes = NANOSECONDS.toMinutes(m)
          val seconds = NANOSECONDS.toSeconds(m) % 60
          s"$minutes minutes and $seconds second${if (seconds == 1) "" else "s"}"
        case h =>
          val hours = NANOSECONDS.toHours(h)
          val minutes = NANOSECONDS.toMinutes(h) % 60
          val seconds = NANOSECONDS.toSeconds(h) % (60 * 60)
          s"$hours hours, $minutes minutes, and $seconds second${if (seconds == 1) ""
          else "s"}"
      }

      val progressReporter = new Thread(() => {
        var lastReportBytes = 0L
        var lastReportTime = startTime
        var aveRate: Option[BigDecimal] = None

        def bytesPerSecond(currentSize: Long, nanoTime: Long): BigDecimal = {
          BigDecimal(currentSize - lastReportBytes) /
            (nanoTime - lastReportTime) * SECONDS.toNanos(1)
        }

        def fmt(rate: BigDecimal): String = {
          (rate / 1024)
            .setScale(2, RoundingMode.HALF_UP)
            .bigDecimal
            .toPlainString
        }

        while (progressAccumulator.get() < contentSize) {
          try {
            Thread.sleep(ProgressInterval)
          } catch {
            case _: InterruptedException =>
              val partTime = System.nanoTime()
              println(
                ".......... 100%" +
                  s" (${fmt(bytesPerSecond(contentSize, partTime))} KiB/s)")
          }

          if (!Thread.interrupted() &&
              progressAccumulator.get() < contentSize) {

            val partTime = System.nanoTime()
            val bytes = progressAccumulator.get()
            val pct = 100 * bytes / contentSize
            val rate = bytesPerSecond(bytes, partTime)

            aveRate = aveRate
              .map(ave => SmoothingFactor * rate + (1 - SmoothingFactor) * ave)
              .orElse(Some(rate))

            val eta = if (aveRate.get == BigDecimal(0)) {
              "∞"
            } else {
              prettyPrint(
                (
                  ((contentSize - bytes) / aveRate.get)
                    * SECONDS.toNanos(1)
                ).longValue()
              )
            }
            println(
              s"${(1L to (pct / 10)).map(_ => ".").mkString} $pct%" +
                s" (${fmt(rate)} KiB/s; ETA $eta)")

            lastReportBytes = bytes
            lastReportTime = partTime
          }
        }
      })
      progressReporter.setDaemon(true)
      progressReporter.setPriority(Thread.MAX_PRIORITY)
      progressReporter.start()

      val outFile = Files.createTempFile("daac", "out")

      val cacheFiles = for {
        download <- downloads
      } yield {
        val part = Await.result(download, Duration.Inf)
        Files.write(outFile, Files.readAllBytes(part), CREATE, APPEND)
        part
      }

      for {
        cacheFile <- cacheFiles
      } {
        Files.delete(cacheFile)
      }

      progressReporter.interrupt()

      val duration = System.nanoTime() - startTime
      val r = (BigDecimal(contentSize) / 1024 / duration * SECONDS.toNanos(1))
        .setScale(2, RoundingMode.HALF_UP)
        .bigDecimal
        .toPlainString

      progressReporter.join()
      println(
        s"Downloaded $contentSize bytes in ${prettyPrint(duration)} ($r KiB/s)")

      Files.move(outFile, destFile, REPLACE_EXISTING)
    }
  }

  cleanUpCacheDir()

  result match {
    case Some(path) => println(s"Saved to $path")
    case None =>
      println(s"Cannot download $url -- better try with your browser.")
      if (Desktop.isDesktopSupported) {
        Desktop.getDesktop.browse(new URI(url))
      }
  }
}
