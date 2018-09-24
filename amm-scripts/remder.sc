/**
 * Render markdown files.
 *
 * Environment variables:
 *
 * REMDER_OUTDIR - output directory, /tmp if unset
 * REMDIR_CSS - CSS file, embedded DefaultCss if unset
 *
 * requires http://ammonite.io/
 */

import $ivy.`com.atlassian.commonmark:commonmark:0.11.0`
import $ivy.`com.atlassian.commonmark:commonmark-ext-gfm-tables:0.11.0`
import $ivy.`com.lihaoyi::scalatags:0.6.7`
import $ivy.`net.sourceforge.plantuml:plantuml:1.2018.11`

import java.awt.Desktop
import java.io._
import java.util
import javax.xml.bind.DatatypeConverter

import ammonite.ops._
import net.sourceforge.plantuml.SourceStringReader
import org.commonmark.ext.gfm.tables.TablesExtension
import org.commonmark.node._
import org.commonmark.parser.Parser
import org.commonmark.renderer.NodeRenderer
import org.commonmark.renderer.html._

import scala.collection.JavaConverters._
import scala.concurrent._
import scala.concurrent.duration.Duration
import scalatags.Text.all._

val outdir = sys.env.get("REMDER_OUTDIR").
  map(f => Path(new File(f).getAbsoluteFile)).
  getOrElse(root / 'tmp)
val css = sys.env.get("REMDER_CSS").
  map(f => Path(new File(f).getAbsoluteFile))

@main
def main(file: File): Unit = {
  val source = read ! Path(file.getAbsoluteFile)
  val hash = source.hashCode

  val title = file.getName.stripSuffix(".md")
  val target = outdir / s"remder-$hash.html"

  if (!target.toIO.exists) {
    write(target, render(title, source))
  }

  Desktop.getDesktop().browse(target.toIO.toURI)
}

def render(title: String, source: String) = {
  val extensions = List(TablesExtension.create()).asJava
  val parser = Parser.builder().
    extensions(extensions).
    build()
  val document = parser.parse(source)
  val renderer = HtmlRenderer.builder().
    nodeRendererFactory(new FencedCodeBlockRenderer(document)).
    extensions(extensions).
    build()
  val output = renderer.render(document)

  val htmlBody = document.getFirstChild match {
    case h: Heading if (h.getLevel == 1) =>
      body(
        raw(output)
      )
    case _ =>
      body(
        h1(title),
        raw(output)
      )
  }

  html(
    head(
      tag("title")(
        title
      ),
      tag("style")(
        raw(css.map(read ! _).getOrElse(DefaultCss))
      )
    ),
    htmlBody
  ).render
}

class FencedCodeBlockRenderer(document: Node) extends HtmlNodeRendererFactory {

  val renderedNodes = {
    val builder = Map.newBuilder[String, Future[String]]

    document.accept(new AbstractVisitor {
      override def visit(fcb: FencedCodeBlock): Unit = {
        import ExecutionContext.Implicits.global

        val nodeType = fcb.getInfo
        if (NodeTypes contains nodeType) {
          val source = fcb.getLiteral
          val hash = source.hashCode.toString
          fcb.setLiteral(hash)

          builder += hash -> Future {
            val targetPath = outdir / s"$hash.png"
            val targetFile = targetPath.toIO

            val bytes = if (!targetFile.exists) {
              val os = new ByteArrayOutputStream()
              new SourceStringReader(s"@start$nodeType\n$source\n@end$nodeType").
                generateImage(os)
              val rendered = os.toByteArray
              Future {
                write(targetPath, rendered)
              }
              rendered
            } else {
              targetPath.getBytes
            }

            DatatypeConverter.printBase64Binary(bytes)
          }
        }
      }
    })

    builder.result()
  }

  override def create(context: HtmlNodeRendererContext): NodeRenderer = {
    val writer = context.getWriter
    val default = new CoreHtmlNodeRenderer(context)

    new NodeRenderer {
      override def getNodeTypes = {
        util.Collections.singleton(classOf[FencedCodeBlock])
      }

      override def render(node: Node): Unit = {
        node match {
          case fcb: FencedCodeBlock if NodeTypes contains fcb.getInfo =>
            val hash = fcb.getLiteral
            val rendered = Await.result(renderedNodes(hash), Duration.Inf)
            val dataUri = s"data:image/png;base64,$rendered"
            val attrs = new util.HashMap[String, String]()
            attrs.put("src", dataUri)

            writer.line()
            writer.tag("img", attrs, true)
            writer.line()
          case _ => default.render(node)
        }
      }
    }
  }
}

val NodeTypes = Set("uml", "salt", "ditaa", "dot", "jcckit")

val DefaultCss = """
* {
    box-sizing: border-box;
}

body {
    word-wrap: break-word;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
    font-size: 12.8px;
    color: black;
    line-height: 1.5;
    padding: 0.7em;
}

p,
blockquote,
ul,
ol,
dl,
table,
pre {
    margin-top: 0;
    margin-bottom: 12.8px;
}

ol ol {
    list-style-type: lower-alpha;
}

ol ol ol {
    list-style-type: lower-roman;
}

p {
    margin: 1em 0;
    line-height: 1.5em;
}

blockquote {
    padding: 0 1em;
    color: #777;
    border-left: 0.25em solid #ddd;
    margin: 0;
}

blockquote>:first-child {
    margin-top: 0;
}

blockquote>:last-child {
    margin-bottom: 0;
}

ul,
ol {
    padding-left: 2em;
}

ul ul,
ul ol,
ol ol,
ol ul {
    margin-top: 0;
    margin-bottom: 0;
}

li+li {
    margin-top: 0.25em;
}

li>p {
    margin-top: 12.8px;
}

dl {
    padding: 0;
}

dl dt {
    padding: 0;
    margin-top: 12.8px;
    font-size: 1em;
    font-style: italic;
    font-weight: bold;
}

dl dd {
    padding: 0 12.8px;
    margin-bottom: 12.8px;
}

table {
    display: block;
    width: 100%;
    overflow: auto;
    font-size: 12.8px;
    border-spacing: 0;
    border-collapse: collapse;
}

table tr {
    border-top: 1px solid #ccc;
}

table th,
table td {
    padding: 6px 13px;
    border: 1px solid #ddd;
}

code {
    padding: 0;
    padding-top: 0.2em;
    padding-bottom: 0.2em;
    margin: 0;
    font-size: 85%;
    border-radius: 3px;
    font-family: Consolas, "Liberation Mono", Menlo, "Courier New", monospace;
}

code::before,
code::after {
    letter-spacing: -0.2em;
    content: "\00a0";
}

pre {
    padding: 12.8px;
    overflow: auto;
    font-size: 85%;
    line-height: 1.45;
    border: 1px solid #ddd;
    border-radius: 3px;
    word-wrap: normal;
}

pre>code {
    font-size: 100%;
    word-break: normal;
    white-space: pre;
    background: transparent;
}

pre code {
    display: inline;
    padding: 0;
    margin: 0;
    overflow: visible;
    line-height: inherit;
    word-wrap: normal;
    background-color: transparent;
    border: 0;
}

pre code::before,
pre code::after {
    content: normal;
}

img {
    box-sizing: content-box;
    border-style: none;
}

a {
    color: #4078c1;
    text-decoration: none;
}

a:hover, a:active {
    text-decoration: underline;
    outline-width: 0;
}

h1, h2, h3, h4, h5, h6 {
    margin-top: 24px;
    margin-bottom: 12.8px;
    font-weight: 600;
    line-height: 1.25;
}

h1 {
    padding-bottom: 0.3em;
    font-size: 2em;
    border-bottom: 1px solid #eee;
}

h1:first-child {
    margin-top:0;
    padding-top:.25em;
    border-top:none;
}

h2 {
    padding-bottom: 0.3em;
    font-size: 1.5em;
    border-bottom: 1px solid #eee;
}

h3 {
    font-size: 1.25em;
}

h4 {
    font-size: 1em;
}

h5 {
    font-size: 0.875em;
}

h6 {
    font-size: 0.85em;
    color: #777;
}

hr {
    height: 0.25em;
    padding: 0;
    margin: 24px 0;
    overflow: hidden;
    background-color: #e7e7e7;
    border:0;
    box-sizing: content-box;
}

@media screen and (min-width: 768px) {
    body {
        width: 748px;
        margin:10px auto;
    }
}
"""
