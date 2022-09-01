
tmpfn="$(mktemp -u)"

read i;
echo $PVDIR/$i > /dev/stderr

ln -s "$PVDIR/$i" "$tmpfn"

# i3-on_open --name 'mupdf' \
#         "floating enable" \
#         "resize set 800 600" \
#         "move position center" \
#         "move right 500 " \
#         "move down 200 " \
#         "border pixel 0" &
# no_focus 	[class="MuPDF"]

mupdf "$tmpfn" &
pid=$!

while read i; do
    ln -sf "$PVDIR/$i" "$tmpfn"
    kill -HUP "$pid"
done

kill "$pid"
