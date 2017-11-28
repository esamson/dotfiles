// write target dir in /tmp
target := {
  file("/tmp/sbt") / (target.value.getPath)
}

// keep generated sources under base directory to keep IDEA happy
sourceManaged := baseDirectory.value / "target" / "src_managed"
resourceManaged := baseDirectory.value / "target" / "resource_managed"

