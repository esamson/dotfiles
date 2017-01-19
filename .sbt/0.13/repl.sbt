libraryDependencies += "com.lihaoyi" % "ammonite" % "0.8.1" % "test" cross CrossVersion.full
initialCommands in (Test, console) := """ammonite.Main().run()"""
