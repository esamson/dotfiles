import scratchpad.Worksheet

/**
  * Worksheet utils
  */
val ws = Worksheet("daac")
def println(msg: String) = ws.log(msg)

import java.net.HttpCookie
import java.net.HttpURLConnection.HTTP_PARTIAL
import java.net.URI
import java.nio.file.StandardCopyOption.REPLACE_EXISTING
import java.nio.file.StandardOpenOption._
import java.nio.file.{Files, Paths}
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit._
import java.util.concurrent.atomic.AtomicLong

import scala.concurrent._
import scala.concurrent.duration.Duration
import scala.math.{min, pow}
import scala.math.BigDecimal.RoundingMode
import scala.util.{Failure, Random, Success, Try}
import scalaj.http._

case class DownloadSpec(url: String, headers: Map[String, IndexedSeq[String]]) {

  def pretty(values: Seq[String]): String = values.length match {
    case 0 => "[]"
    case 1 => values.head
    case _ => values.mkString("[\n    ", "\n    ", "  \n]")
  }

  def prettyPrint(headers: Map[String, IndexedSeq[String]]): String = {
    headers.map({ case (header, values) => s"$header = ${pretty(values)}" })
      .mkString("\n  ")
  }

  override def toString: String =
    s"""DownloadSpec($url
       |  ${prettyPrint(headers)}
       |)""".stripMargin
}

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
    case r if r.isRedirect => inspect(r.location.get, cookies)
    case s if s.code == HTTP_PARTIAL => Option(s.body)
    case x =>
      println(s"Cannot download. Server returned ${x.code}; ${x.headers}")
      None
  }
}

val MaxBackoffMs = 10000
val BackoffSlotMs = 100
val MaxBackoffSlots = Stream
  .from(1)
  .filter(n => (pow(2, n).toInt - 1) * BackoffSlotMs > MaxBackoffMs)
  .head

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
    case Failure(ex) => ex match {
      case ex: AssertionError => throw ex
      case cause =>
        if ((backoffSlots + 1) % 10 == 0) {
          println(s"Try ${backoffSlots + 1} failed. $cause")
        }
        retry(backoffSlots + 1)(f)
    }
  }
}

def download(req: HttpRequest, progressAccumulator: AtomicLong)(
  implicit ec: ExecutionContext) = Future {
  retry() {
    val response = blocking {
      req.asBytes
    }

    if (response.code != HTTP_PARTIAL) {
      throw new AssertionError(
        s"Expected $HTTP_PARTIAL but got ${response.code}")
    }

    val contentLength = response.header("Content-Length")
      .map(_.toInt)
      .getOrElse(throw new AssertionError("No Content-Length"))

    require(contentLength == response.body.length,
      s"Expected $contentLength bytes but downloaded ${response.body.length}.")

    progressAccumulator.addAndGet(response.body.length)

    val tmpFile = Files.createTempFile("daac", "tmp")
    tmpFile.toFile.deleteOnExit()
    Files.write(tmpFile, response.body)
    tmpFile
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

// main
def main(url: String) = {
  val result = for {
    spec <- inspect(url, cookies(url))
    contentRange <- spec.headers.get("Content-Range").flatMap(_.headOption)
    contentSize <- contentRange.split('/').last match {
      case "*" => None
      case size => Some(size.toLong)
    }
  } yield {
    println(s"Downloading: $spec")
    val fileName = spec.headers.get("Content-Disposition")
      .flatMap(_.headOption)
      .flatMap { contentDisposition =>
        contentDisposition.split(""";\s*""")
          .find(_.startsWith("filename"))
          .map(_.split('=').last)
      }
      .getOrElse(new URI(spec.url).getPath.split('/').last)
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
        request.header("Range", s"bytes=$start-$end")
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
      case ns if NANOSECONDS.toMicros(ns) <= 1 => s"$ns nanosecond${if (ns == 1) "" else "s"}"
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
        s"$hours hours, $minutes minutes, and $seconds second${if (seconds == 1) "" else "s"}"
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
          .bigDecimal.toPlainString
      }

      while (progressAccumulator.get() < contentSize) {
        try {
          Thread.sleep(ProgressInterval)
        } catch {
          case _: InterruptedException =>
            val partTime = System.nanoTime()
            println(".......... 100%" +
              s" (${fmt(bytesPerSecond(contentSize, partTime))} KiB/s)")
        }

        if (!Thread.interrupted() &&
          progressAccumulator.get() < contentSize) {

          val partTime = System.nanoTime()
          val bytes = progressAccumulator.get()
          val pct = 100 * bytes / contentSize
          val rate = bytesPerSecond(bytes, partTime)

          aveRate = aveRate.map(ave =>
            SmoothingFactor * rate + (1 - SmoothingFactor) * ave
          ).orElse(Some(rate))

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
          println(s"${(1L to (pct / 10)).map(_ => ".").mkString} $pct%" +
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

    downloads.zipWithIndex.foreach { case (download, _) =>
      val part = Await.result(download, Duration.Inf)
      Files.write(outFile, Files.readAllBytes(part), CREATE, APPEND)
    }

    progressReporter.interrupt()

    val duration = System.nanoTime() - startTime
    val r = (BigDecimal(contentSize) / 1024 / duration * SECONDS.toNanos(1))
      .setScale(2, RoundingMode.HALF_UP)
      .bigDecimal.toPlainString

    progressReporter.join()
    println(s"Downloaded $contentSize bytes in ${prettyPrint(duration)} ($r KiB/s)")

    val destFile = Paths.get(sys.props("user.dir")).resolve(fileName)
    Files.move(outFile, destFile, REPLACE_EXISTING)
    s"Saved to $destFile"
  }

  println(result.getOrElse(s"Failed downloading $url"))
}

//val url = "http://mirrors.jenkins.io/war-stable/latest/jenkins.war"
val url = "https://github.com/yhatt/marp/releases/download/v0.0.10/0.0.10-Marp-darwin-x64.dmg"
//val url = "http://alaska.epfl.ch/~dockermoocs/parprog1/scalashop.zip"
main(url)
