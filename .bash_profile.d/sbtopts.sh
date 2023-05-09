sbt_opts_file="$HOME/.config/sbt/sbtopts"
if [ -f "$sbt_opts_file" ]; then
    export SBT_ETC_FILE="$sbt_opts_file"
fi
