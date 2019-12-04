kafka_home=$HOME/.local/opt/kafka
if [ -f $kafka_home/bin/kafka-topics.sh ]; then
    # We could also just
    #     pathmunge $kafka_home/bin after
    # But we'll alias to names without `.sh` suffix so usage is the same as
    # when Kafka is installed on macOS using Homebrew.
    for script_sh in $kafka_home/bin/*.sh; do
        [ -e "$script_sh" ] || continue
        file=${script_sh##*/}
        name=${file%.*}
        alias $name=$script_sh
    done
fi
unset kafka_home
