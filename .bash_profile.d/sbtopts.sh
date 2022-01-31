if [ -f "$HOME/.sbt/repositories" ]; then
  export SBT_OPTS="-Dsbt.override.build.repos=true"
fi
