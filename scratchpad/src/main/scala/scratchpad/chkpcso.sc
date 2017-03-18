import scratchpad.Worksheet

/**
  * Worksheet utils
  */
val ws = Worksheet("chkpcso")
def println(msg: String) = ws.log(msg)

import org.jsoup.Jsoup
import scala.collection.JavaConverters._
import scala.util.Random

case class GameResult(
    game: String,
    combination: List[Int],
    drawDate: String,
    jackpot: BigDecimal,
    winners: Int
)

def parseCombination(combination: String): List[Int] = {
  combination.split("\\s*-\\s*").map(_.toInt).toList
}

val ResultsUrl = "http://www.pcso.gov.ph/lotto-search/lotto-search.aspx"

val resultsDocument = Jsoup.connect(ResultsUrl).get()
val rows = resultsDocument.select("#GridView1 tbody > tr")
val results = rows.asScala map { row =>
  row.getElementsByTag("td")
} filter { cells =>
  cells.size() == 5
} map { cells =>
  GameResult(
    game = cells.get(0).text().trim(),
    combination = parseCombination(cells.get(1).text().trim()),
    drawDate = cells.get(2).text().trim(),
    jackpot = BigDecimal(cells.get(3).text().trim().replaceAll(",", "")),
    winners = cells.get(4).text().trim().toInt
  )
} filter { result =>
  result.combination.length == 6
}

//@main
def chkpcso(combination: Int*) = {
  if (combination.length != 6) {
    println(
      s"""Provide your 6 game numbers like so:
         |chkpcso ${(1 to 6).map(_ => Random.nextInt(42) + 1).mkString(" ")}
       """.stripMargin)
  } else {
    val (winners, losers) = results partition { result =>
      result.combination.count(combination.contains(_)) >= 4
    }
    val bigJackpot = losers.filter(_.jackpot > 100000000)

    println(s"Found ${results.size}" +
        s" result${if (results.size != 1) "s" else ""}." +
        s"${
          if (winners.isEmpty && bigJackpot.isEmpty)
            " Nothing interesting." else ""
        }")
    if (winners.nonEmpty)
      println(s"Winners:\n${winners.mkString("\n")}")
    if (bigJackpot.nonEmpty)
      println(s"Big jackpot:\n${bigJackpot.mkString("\n")}")
  }
}

chkpcso(21, 22, 3, 39, 4, 8)
