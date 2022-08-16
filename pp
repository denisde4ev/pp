#!/bin/sh

die() {
	printf %s\\n >&2 "Error: $1" \
		"Usage: ${0##*/} v0.2.0" \
		"  * STDIN | ${0##*/} > output -- See pp(1) for details and examples" \
		"Syntax:" \
		"  * Lines beginning !! are replaced with the following text evaluated" \
		"    as a shell command." \
		"  * Section !{...}! on one line is replaced by the output of cmd '...'" \
		"  * Variables to use: \$ln for line no. \$line for line itself" \
	;
	exit 1
}

middle() {
	no_front=${1#*\!{}
	eval "${no_front%\}\!*}" || die "Line $ln: section evaluation error"
}

process() {
	while IFS= read -r line; do
		ln=$((ln+1))
		case $line in
			!!*) eval "${line##!!}" 2>/dev/null || die "LINE $ln: evaluation error";;
			*!\{*\}!*) printf %s%s%s\\n "${line%%\!{*}" "$(middle "$line")" "${line##*\}\!}";;
			*) echo "$line";;
		esac
	done
}

[ $# -ne 0 ] && die "No arguments are taken"
[ -t 0 ] && die "No input text provided"
process
