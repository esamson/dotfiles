// Disable checksum
// https://github.com/coursier/coursier/issues/319
import coursier.CoursierPlugin.autoImport._

coursierChecksums := Nil
coursierArtifactsChecksums := Nil
