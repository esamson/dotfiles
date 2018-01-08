/**
  * Share a file or directory over HTTP
  */

import $ivy.{
  `com.lihaoyi::scalatags:0.6.7`,
  `com.lihaoyi::ammonite-ops:1.0.3`,
  `com.typesafe.play::play:2.6.7`,
  `com.typesafe.play::play-akka-http-server:2.6.7`,
  `org.slf4j:slf4j-nop:1.7.25`
}

import java.awt.Desktop
import java.net.{NetworkInterface, URI}
import java.nio.charset.StandardCharsets.UTF_8
import java.nio.file.Files

import akka.stream.scaladsl.{FileIO, StreamConverters}
import ammonite.ops.ImplicitWd._
import ammonite.ops._
import play.api.http.HeaderNames._
import play.api.http.Status._
import play.api.http.{ContentTypeOf, ContentTypes, HttpEntity, Writeable}
import play.api.mvc._
import play.api.routing.sird._
import play.core.server.{AkkaHttpServer, ServerConfig}
import play.utils.UriEncoding

import scala.collection.JavaConverters._
import scalatags.Text
import scalatags.Text.all._

@main
def main(base: Path = pwd) = {
  val port = 1024 + Math.abs(base.toString().hashCode % (65535 - 1024))
  val urlPath = if (base.isDir) {
    ""
  } else {
    UriEncoding.encodePathSegment(base.name, UTF_8)
  }
  val url = for {
    nif <- NetworkInterface.getNetworkInterfaces.asScala.toList
    if !nif.isLoopback
    if !nif.isPointToPoint
    if nif.isUp
    addr <- nif.getInetAddresses.asScala.toList
    if addr.isSiteLocalAddress
  } yield s"http://${addr.getHostAddress}:$port/$urlPath"
  println(s"sharing $base at ${url.mkString(" ")}")

  sys.props("config.file") = tmp().toString()
  sys.props("play.http.secret.key") = "secret"

  def checkMimeType(target: String) = %%('file, "--mime", "-b", target) match {
    case r@CommandResult(0, _) => r.out.trim
    case fail =>
      println(s"Can't determine MIME type. $fail")
      "application/octet-stream"
  }

  val server = AkkaHttpServer.fromRouterWithComponents(
    ServerConfig(port = Some(port))
  ) { components =>
    import Results._
    import components.{defaultActionBuilder => Action}
  {
    case GET(request) =>
      println(s"$request: ${request.headers}")
      val target = if (base.isDir) {
        if (request.target.path == "/") {
          base.toNIO
        } else {
          base.toNIO.resolve(UriEncoding.decodePath(
            request.target.path.stripPrefix("/"), UTF_8))
        }
      } else {
        base.toNIO
      }
      println(s"serving $target")

      if (Files.isDirectory(target)) {

        implicit def contentTypeOfTag(implicit codec: Codec): ContentTypeOf[Tag] = {
          ContentTypeOf[Tag](Some(ContentTypes.HTML))
        }

        implicit def writeableOfTag(implicit codec: Codec): Writeable[Tag] = {
          Writeable(tag => codec.encode("<!DOCTYPE html>\n" + tag.render))
        }

        def dirList(dir: java.nio.file.Path): Text.TypedTag[String] = ol(
          for {
            entry <- dir.toFile.listFiles().sorted
            if !entry.isHidden
          } yield {
            val path = base.toNIO.relativize(entry.toPath).asScala
                .map(s => UriEncoding.encodePathSegment(s.toString, UTF_8))
                .mkString("/")
            if (entry.isDirectory) {
              li(
                a(href := s"/$path/")(s"${entry.getName}/"),
                dirList(entry.toPath)
              )
            } else {
              li(
                a(href := s"/$path")(s"${entry.getName}")
              )
            }
          }
        )

        val rel = base.toNIO.relativize(target)

        Action {
          Ok(html(
            head(
              meta(charset := "utf-8"),
              meta(name := "viewport",
                content := "width=device-width, initial-scale=1"),
              tag("title")(s"${base.segments.last}")
            ),
            body(
              h1(
                Option(rel.getParent).map(parent => {
                  a(href := s"/$parent")(s"/$parent/")
                }).getOrElse(
                  if (rel.toString.isEmpty) {
                    ""
                  } else {
                    a(href := "/")("/")
                  }
                ),
                s"${rel.getFileName}/"
              ),
              dirList(target)
            )
          ))
        }
      } else if (Files.isReadable(target)) {
        val mimeType = checkMimeType(target.toString)
        println(s"mime-type: $mimeType")

        request.headers.get(RANGE) match {
          case None => Action {
            val source = FileIO.fromPath(target)
            Result(
              header = ResponseHeader(200, Map(
                ACCEPT_RANGES -> "bytes"
              )),
              body = HttpEntity.Streamed(
                source,
                Some(Files.size(target)),
                Some(mimeType)
              )
            )
          }

          case Some(range) if !range.contains("bytes=") => Action {
            BadRequest(s"bad $RANGE: $range")
          }

          case Some(range) => Action {
            val fileLength = Files.size(target)
            val (start, end) = range.substring("bytes=".length).split("-") match {
              case x if x.length == 1 => x.head.toLong -> (fileLength - 1)
              case x => x(0).toLong -> x(1).toLong
            }
            if (start < 0 || end < 0 || start >= fileLength || end >= fileLength) {
              Status(REQUESTED_RANGE_NOT_SATISFIABLE).withHeaders(
                CONTENT_RANGE -> "bytes */%d".format(fileLength)
              )
            } else {
              val stream = Files.newInputStream(target)

              stream.skip(start)

              val source = StreamConverters.fromInputStream(() => stream)
              Result(
                header = ResponseHeader(200, Map(
                  CONNECTION -> "keep-alive",
                  ACCEPT_RANGES -> "bytes",
                  CONTENT_RANGE -> "bytes %d-%d/%d".format(start, end, fileLength)
                )),
                body = HttpEntity.Streamed(
                  source,
                  Some(Files.size(target)),
                  Some(mimeType)
                )
              )
            }
          }
        }
      } else {
        Action {
          NotFound(s"$request somewhere else.")
        }
      }
  }
  }

  try {
    println("'q' <enter> quits")
    if (url.nonEmpty &&
        (base.isDir || checkMimeType(base.toString()).startsWith("text"))) {
      Desktop.getDesktop.browse(URI.create(url.head))
    }
    var key = System.in.read()
    while (key != 'q') {
      key = System.in.read()
    }
  } finally {
    println("stopping")
    server.stop()
    println("bye")
  }
}
