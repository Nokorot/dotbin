
TrashDir="$HOME/.local/share/Trash"

delPerm() {
  for k in "$@"; do 
    rm -r "$TrashDir/files/$k"
    rm -r "$TrashDir/info/$k.trashinfo"
  done 
}

empty() {
  rm -r "$TrashDir/files/"*
  rm -r "$TrashDir/info/"*
}

restore() {
  path="$(getPath "$1")"
  echo "Restoring: \"$file\"" 
  echo "      -> \"$path\""

  mv -i "$TrashDir/files/$1" "$path"
  rm "$TrashDir/info/$1.trashinfo"
}

sep='¤'
listFiles() {
    ls "$TrashDir/files" | while read l; do
    printf "%s $sep %s $sep (%s)\n" \
        "$(getDate "$l")" \
        "$l$([ -d "$TrashDir/files/$l" ] && printf "/")" \
        "$(getPath "$l")"
    done \
        | align -clmn 1 -l "$sep" \
        | sort -r
}

filenameFromLine() {
    sed -e 's/.*¤ \(.*\) ¤.*/\1/' -e 's,/*[ ]*$,,' 
}


getPath() {
    [ -f "$TrashDir/info/$1.trashinfo" ] || { return; }
    cat "$TrashDir/info/$1.trashinfo" \
        | grep '^Path=' \
        | sed 's/^Path=//';
}

getDate() {
    [ -f "$TrashDir/info/$1.trashinfo" ] || { return; }
    cat "$TrashDir/info/$1.trashinfo" \
        | grep 'Date=' \
        | sed 's/.*Date=//';
}

## Could do sub-commands

