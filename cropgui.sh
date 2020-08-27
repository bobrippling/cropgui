#!/bin/sh

d="$(readlink -f "$(dirname "$0")")"

cgpy="$d/cropgui.py"

#passthru(){
#	exec "$cgpy" "$@"
#	exit $?
#}

usage(){
	echo >&2 "Usage: $0 file"
	exit 2
}

if test $# -ne 1
then usage
fi

if ! test -e "$1"
then usage
fi

#if ! echo "$1" | grep -E '\.(png|gif)$' >/dev/null
#then passthru "$@"
#fi

echo "$0: converting $1 to jpg"

t="${TMPDIR:-/tmp}/$$.jpg"
o="${TMPDIR:-/tmp}/$$-crop.jpg"

convert "$1" "$t" || exit $?

trap "rm -f $t" EXIT

"$cgpy" "$t"

echo "$0: TODO: filename stuff" >&2

mv -i "$o" "$(dirname "$1")"
