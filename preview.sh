#!/bin/bash

tmpfn="$(mktemp -u)"

read i;
# echo $PVDIR/$i > /dev/stderr

ln -s "$PVDIR/$i" "$tmpfn"

open() {
    echo $pwd

    [ -z "$pid" ] || kill "$pid"

    { 
        id="$(i3-msg -t get_focused | jq '.window')"
        echo "ID: $id"
        i3-on_open \
            "floating enable" \
            "resize set 800 600" \
            "move position center" \
            "move right 500 " \
            "move down 200 " \
            "border pixel 0" \
            "_ i3-msg [id=$id] focus"
    } &
    
    ONSTART="< '$PVDIR/$i' less" kitty --class="MuPDF"&
    pid=$!
}

open

while read i; do
    open
done
