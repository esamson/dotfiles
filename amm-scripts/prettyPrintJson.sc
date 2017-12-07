/**
 * Pretty print a given JSON file. If no file is given, read stdin.
 *
 * requires http://ammonite.io/
 */

import $ivy.`com.typesafe.play::play-json:2.6.7`
import java.io._
import play.api.libs.json.Json

@main
def main(file: File = null) = {
  val in = if (file != null) {
    new BufferedInputStream(new FileInputStream(file))
  } else {
    System.in
  }

  try {
    println(Json.prettyPrint(Json.parse(in)))
  } finally {
    in.close()
  }
}
