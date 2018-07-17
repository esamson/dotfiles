import $ivy.`com.github.pathikrit::better-files:3.5.0`
import $ivy.`commons-io:commons-io:2.6`

import java.io.{BufferedReader, InputStreamReader, PrintWriter}
import java.nio.charset.{Charset, StandardCharsets}

import ammonite.ops._
import better.files._
import org.apache.commons.io.ByteOrderMark
import org.apache.commons.io.input.BOMInputStream

@main
def main(files: Path*) = {
  if (files.isEmpty) {
    println(
      s"""|Usage: retext FILE ...
          |
          |Read the given text FILE(s) and rewrite to a new file using the
          |standard platform line separator.
          |
          |The source FILE(s) will be read using the platform default charset
          |unless the SOURCE_CS environment variable is defined. The target file
          |will be written using UTF-8 unless the TARGET_CS environment variable
          |is defined.
          |
          |  E.g.,
          |
          |    SOURCE_CS=UTF-16 TARGET_CS=UTF-32 retext FILE
          |
          |The target file name will be the source file name prefixed with the
          |target charset name.
          |""".stripMargin
    )
    sys.exit(1)
  } else {
    val sourceCharset = sys.env
      .get("SOURCE_CS")
      .map(Charset.forName)
      .getOrElse(DefaultCharset)
    val targetCharset = sys.env
      .get("TARGET_CS")
      .map(Charset.forName)
      .getOrElse(StandardCharsets.UTF_8)
    files.foreach(file => transform(sourceCharset, targetCharset, file))
  }
}

def transform(sourceCharset: Charset, targetCharset: Charset, file: Path) = {
  val source = File(file.toNIO)
  val target = source.sibling(s"$targetCharset.${source.name}")
  println(s"transforming $source ($sourceCharset) -> $target ($targetCharset)")

  val reader: BufferedReader = sourceCharset.toString match {
    case "UTF-8" | "UTF-16" | "UTF-16BE" | "UTF-16LE" | "UTF-32BE" |
        "UTF-32LE" =>
      new BufferedReader(
        new InputStreamReader(
          new BOMInputStream(
            source.newInputStream,
            ByteOrderMark.UTF_8,
            ByteOrderMark.UTF_16BE,
            ByteOrderMark.UTF_16LE,
            ByteOrderMark.UTF_32BE,
            ByteOrderMark.UTF_32LE
          ),
          sourceCharset
        )
      )
    case _ => source.newBufferedReader(sourceCharset)
  }

  val writer = new PrintWriter(target.newBufferedWriter(targetCharset))
  reader.lines().forEachOrdered(line => writer.println(line))
  reader.close()
  writer.close()
}
