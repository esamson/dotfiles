/**
  * Scaffolding for editing amm scripts in IntelliJ IDEA
  */
lazy val root = (project in file(".")).settings(
  inThisBuild(
    List(
      organization := "ph.samson.dotfiles",
      scalaVersion := "2.12.4",
      version := "0.1.0-SNAPSHOT"
    )),
  name := "amm-scripts",
  libraryDependencies ++= Seq(
    "com.lihaoyi" %% "ammonite" % ammoniteVersion cross CrossVersion.full,
    "com.lihaoyi" %% "ammonite-ops" % ammoniteVersion,
    "com.typesafe.play" %% "play" % playVersion,
    "com.typesafe.play" %% "play-json" % playVersion,
    "com.typesafe.play" %% "play-akka-http-server" % playVersion,
    "com.atlassian.commonmark" % "commonmark" % "0.11.0",
    "com.atlassian.commonmark" % "commonmark-ext-gfm-tables" % "0.11.0",
    "com.lihaoyi" %% "scalatags" % "0.6.7",
    "net.sourceforge.plantuml" % "plantuml" % "1.2018.7"
  )
)
val ammoniteVersion = "1.0.3"
val playVersion = "2.6.7"
