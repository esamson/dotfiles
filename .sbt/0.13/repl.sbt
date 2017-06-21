libraryDependencies += "com.lihaoyi" % "ammonite" % "0.9.9" % "test" cross CrossVersion.full
initialCommands in (Test, console) := """ammonite.Main().run()"""
