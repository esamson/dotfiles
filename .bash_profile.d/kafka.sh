kafka_home=$HOME/.local/opt/kafka
if [ -f $kafka_home/bin/kafka-topics.sh ]; then
    pathmunge $kafka_home/bin after

    if [ ! -f $kafka_home/bin/kafka-topics ]; then
        # We'll link to names without `.sh` suffix so usage is the same as
        # when Kafka is installed on macOS using Homebrew.
        for script_sh in $kafka_home/bin/*.sh; do
            [ -e "$script_sh" ] || continue
            file=${script_sh##*/}
            name=${file%.*}
            if [ ! -f $kafka_home/bin/$name ]; then
                ln -s $script_sh $kafka_home/bin/$name
            fi
        done
    fi
fi
unset kafka_home
