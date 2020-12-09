#!/bin/sh

set -eu

usage(){
	echo >&2 "Usage: $0 file"
	exit 2
}

del_on_exit(){
	trap "rm '$1'" EXIT
}

if test $# -ne 1
then usage
fi

f="$1"
orig_f="$f"
if ! test -e "$f"
then usage
fi

dir="$(readlink -f "$(dirname "$0")")"
scriptname="${0##*/}"
cropgui_py="$dir/cropgui.py"

as_jpg=
if ! echo "$f" | grep -E '\.jpe?g$' >/dev/null
then
	printf '%s: converting \"%s\" to jpg... ' "$scriptname" "$f"

	as_jpg="${TMPDIR:-/tmp}/$$.jpg"

	convert "$f" "$as_jpg" || exit $?
	del_on_exit "$as_jpg"
	f="$as_jpg"

	printf 'done\n'
fi

log="/tmp/cropgui.$$"
del_on_exit "$log"
if ! "$cropgui_py" "$f" >"$log" 2>&1
then
	cat >&2 "$log"
	exit $?
fi
output="${f%.*}-crop.jpg"

cropped="${orig_f%.*}-cropped.jpg"
if test -e "$cropped"
then
	i=1
	while :
	do
		i=$(expr $i + 1)
		cropped="${orig_f%.*}-cropped-$i.jpg"
		if ! test -e "$cropped"
		then break
		fi
	done
fi

mv "$output" "$cropped"
printf '%s: saved as %s\n' "$scriptname" "$cropped"
