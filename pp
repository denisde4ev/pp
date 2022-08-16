#!/bin/sh

case $1 in
--help)
	printf %s\\n \
		"Usage: ${0##*/} v0.2.0" \
		"  * STDIN | ${0##*/} > output -- See pp(1) for details and examples" \
		"Syntax:" \
		"  * Lines beginning !! are replaced with the following text evaluated" \
		"    as a shell command." \
		"  * Section !{...}! on one __LINE__ is replaced by the output of cmd '...'" \
		"  * Variables to use: \$__LINU_NUMBER for line no. \$__LINE__ for line itself" \
	;;
-)
	printf %s\\ "see --help for usage"
esac


_die_() {
	printf %s\\n >&2 "Error: $1"
	exit 1
}
[ $# -ne 0 ] && _die_ "No arguments are taken"

_middle_() {
	___no_front___=${1#*\!{}
	eval "${___no_front___%\}\!*}" || _die_ "Line $__LINU_NUMBER: section evaluation error"
}

pp() {
	while IFS= read -r __LINE__; do
		__LINU_NUMBER=$((__LINU_NUMBER+1))
		case $___LINE__ in
			!!|!!#*|'!! #'*|'!!	#'*) ;;
			!!*) eval "${__LINE__##!!}" 2>/dev/null || _die_ "LINE $__LINU_NUMBER: evaluation error";;
			*!\{*\}!*) printf %s%s%s\\n "${__LINE__%%\!{*}" "$(_middle_ "$__LINE__")" "${__LINE__##*\}\!}";;
			*) echo "$__LINE__";;
		esac
	done
}
pp "$@"
