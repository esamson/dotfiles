sbt_opts_file="$HOME/.local/etc/sbtopts"
if [ -f "$sbt_opts_file" ]; then
    export SBT_ETC_FILE="$sbt_opts_file"
fi
