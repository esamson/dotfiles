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
    "com.lihaoyi" %% "ammonite" % "1.0.3" cross CrossVersion.full,
    "com.typesafe.play" %% "play-json" % "2.6.7",
    "com.atlassian.commonmark" % "commonmark" % "0.8.0",
    "com.atlassian.commonmark" % "commonmark-ext-gfm-tables" % "0.8.0",
    "com.lihaoyi" %% "scalatags" % "0.6.2",
    "net.sourceforge.plantuml" % "plantuml" % "1.2017.19"
  )
)
