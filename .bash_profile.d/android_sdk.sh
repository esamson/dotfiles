android_sdk=$HOME/.local/opt/android_sdk
if [ -f $android_sdk/platform-tools/adb ]; then
    pathmunge $android_sdk/platform-tools after
fi
unset android_dsk
