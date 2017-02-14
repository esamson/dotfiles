import java.net.HttpURLConnection.HTTP_PARTIAL
import java.nio.file.StandardCopyOption.REPLACE_EXISTING
import java.nio.file.StandardOpenOption._
import java.nio.file.{Files, Paths}
import java.util.concurrent.{Executors, ThreadFactory}
import java.util.concurrent.TimeUnit._

import scala.concurrent._
import scala.concurrent.duration.Duration
import scala.math.{min, pow}
import scala.util.{Failure, Random, Success, Try}
import scalaj.http._
import scratchpad.Worksheet

val ws = Worksheet("daac")
def println(msg: String) = ws.log(msg)

case class DownloadSpec(url: String, headers: Map[String, IndexedSeq[String]])

@scala.annotation.tailrec
def inspect(url: String): Option[DownloadSpec] = {
  val req = Http(url)
    .header("Range", s"bytes=0-0")
  val probe = req.exec((code, headers, inputStream) => {
    // ignore body
    inputStream.close()
    DownloadSpec(url, headers)
  })

  probe match {
    case r if r.isRedirect => inspect(r.location.get)
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

def download(req: HttpRequest)(implicit ec: ExecutionContext) = Future {
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

    val tmpFile = Files.createTempFile("daac", "tmp")
    tmpFile.toFile.deleteOnExit()
    Files.write(tmpFile, response.body)
    tmpFile
  }
}

val SplitSize = 1L << 17

def main(url: String) = {
  val result = for {
    spec <- inspect(url)
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
      .getOrElse(spec.url.split('/').last)
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

    val threadPool = Executors.newFixedThreadPool(100, new ThreadFactory {
      override def newThread(r: Runnable) = {
        val thread = new Thread(r)
        thread.setDaemon(true)
        thread
      }
    })
    implicit val executionContext = ExecutionContext.fromExecutor(threadPool)

    val startTime = System.nanoTime()
    val downloads = splits.map { request =>
      download(request)
    }

    def printRate(bytes: Long) = {
      val now = System.nanoTime()
      val durationSecs = NANOSECONDS.toSeconds(now - startTime)
      if (durationSecs > 0) {
        println(s"$bytes bytes in $durationSecs seconds (${bytes / 1024 / durationSecs} KiB/s)")
      } else {
        println(s"$bytes bytes in less than a second")
      }
    }

    val outFile = Files.createTempFile("daac", "out")

    downloads.zipWithIndex.foreach { case (download, index) =>
      val part = Await.result(download, Duration.Inf)
      if ((index + 1) % 100 == 0) {
        printRate((index + 1) * SplitSize)
      }
      Files.write(outFile, Files.readAllBytes(part), CREATE, APPEND)
    }

    printRate(contentSize)

    val destFile = Paths.get(sys.props("user.dir")).resolve(fileName)
    Files.move(outFile, destFile, REPLACE_EXISTING)
    s"Saved to $destFile"
  }

  println(result.getOrElse(s"Failed downloading $url"))
}

//val url = "http://mirrors.jenkins.io/war-stable/latest/jenkins.war"
val url = "https://github.com/yhatt/marp/releases/download/v0.0.10/0.0.10-Marp-darwin-x64.dmg"
main(url)
