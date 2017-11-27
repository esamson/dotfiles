// write target dir in /tmp
target := {
  file("/tmp/sbt") / (baseDirectory.value.getParent) / name.value
}

// keep generated sources under base directory to keep IDEA happy
sourceManaged := baseDirectory.value / "target" / "src_managed"
resourceManaged := baseDirectory.value / "target" / "resource_managed"

