#!/usr/bin/env bash
#
# `brew linkapps` creates symlinks that aren't picked up by Spotlight so they
# can't be launched from there. The solution is to create a Finder alias
# instead.
#
# https://github.com/Homebrew/legacy-homebrew/issues/8970
# http://stackoverflow.com/a/10067437/55334

__linkapp() {
    local app=$1
    local target=$2

    echo "Linking $app"
    appname=$(basename "$app")
    linkname="${appname%.*}"
    if [ -f "$target/$linkname" ]; then
        rm "$target/$linkname"
    fi
    osascript -e "tell application \"Finder\" to make alias file to POSIX file \"$app\" at POSIX file \"$target\""
}

FORMULA=$1

if [ -z $FORMULA ]; then
    CELLAR_DIR=$(brew --prefix)/opt
else
    CELLAR_DIR=$(brew --prefix $FORMULA)
fi
DIR=$HOME/Applications

if [ -z $CELLAR_DIR ]; then
    exit 1
fi

found="$TMPDIR"brew-better-linkapps.found.$RANDOM
find -L $CELLAR_DIR -name "*.app" | sed "s|$CELLAR_DIR/||" > $found

declare -a apps
count=0
while read app; do
    apps[$count]=$app
    count=$((count + 1))
done <$found
rm $found

if [ ${#apps[@]} -eq 0 ]; then
    echo "No linkable apps for $FORMULA"
    exit 2
elif [ ${#apps[@]} -eq 1 ]; then
    __linkapp "$CELLAR_DIR/${apps[0]}" "$DIR"
else
    echo "Found ${#apps[@]} apps:"
    echo
    for i in "${!apps[@]}"; do
        echo "[$i]: ${apps[$i]}"
    done

    echo
    echo -n "Which app? [0 - $i] or all, otherwise: "
    read pick

    if [ $pick -eq $pick >/dev/null 2>&1 ] \
    && [ $pick -ge 0 >/dev/null 2>&1 ] \
    && [ $pick -le $i ]; then
        __linkapp "$CELLAR_DIR/${apps[$pick]}" "$DIR"
    else
        echo "Linking all"
        for i in "${!apps[@]}"; do
            __linkapp "$CELLAR_DIR/${apps[$i]}" "$DIR"
        done
    fi
fi
