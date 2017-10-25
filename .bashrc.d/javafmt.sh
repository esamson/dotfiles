# https://github.com/google/google-java-format/pull/50#issuecomment-223630180
javafmt() {
    DIR="$1"
    if [ -z "$DIR" ]; then
        DIR="."
    fi
    find "$DIR" -type f -name "*.java" | xargs google-java-format --replace --aosp
}
