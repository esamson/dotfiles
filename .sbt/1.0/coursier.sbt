// Disable checksum
// https://github.com/coursier/coursier/issues/319
import coursier.CoursierPlugin.autoImport._

coursierChecksums := Nil
coursierArtifactsChecksums := Nil

// Handle `maven-plugin` packaging type
// https://github.com/coursier/coursier/issues/450
classpathTypes += "maven-plugin"
