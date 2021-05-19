val tmpTargetEnabled = !sys.env.get("SBT_TMP_TARGET").exists(_ == "false")

// write target dir in /tmp
target := {
  if (tmpTargetEnabled) {
    file(s"/tmp/sbt_${sys.props("user.name")}") / (target.value.getPath)
  } else {
    target.value
  }
}
