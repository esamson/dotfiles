android_sdk=$HOME/.local/opt/android_sdk
if [ -f $android_sdk/platform-tools/adb ]; then
    export ANDROID_HOME=$android_sdk
    pathmunge $ANDROID_HOME/platform-tools after
fi
unset android_dsk
