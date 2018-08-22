if (!sys.env.get("SBT_TMP_TARGET").exists(_ == "false")) {
  // write target dir in /tmp
  target := {
    file(s"/tmp/sbt_${sys.props("user.name")}") / (target.value.getPath)
  }

  // keep generated sources under base directory to keep IDEA happy
  sourceManaged := baseDirectory.value / "target" / "src_managed"
  resourceManaged := baseDirectory.value / "target" / "resource_managed"
} else {
  target := target.value
}
