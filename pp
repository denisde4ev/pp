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
		"  * Variables to use: \$__LINE_NUMBER__ for line no. \$__LINE__ for line itself" \
	;
	exit
	;;
-)
	printf %s\\n >&2 "see --help for usage"
	exit 2
esac


_die_() {
	printf %s\\n >&2 "Error: $1"
	exit "${2-2}"
}

[ $# -ne 0 ] && _die_ "No arguments are taken"


pp() {
	while IFS= read -r __LINE__; do
		__LINE_NUMBER__=$((__LINE_NUMBER__+1))
		case $__LINE__ in
			!!|!!#*|'!! #'*|'!!	#'*) ;;
			!!*)
				eval "${__LINE__##!!}" || {
					_die_ "LINE $__LINE_NUMBER__: evaluation error $?" 3
				}
			;;
			*!\{*\}!*)
				__pp_tmp__=${1#*\!{}
				__pp_tmp__=$(eval "${__pp_tmp__%\}\!*}") || {
					_die_ "Line $__LINE_NUMBER__: section evaluation error $?" 3
				}
				printf %s%s%s\\n \
					"${__LINE__%%\!{*}" \
					"$__pp_tmp__" \
					"${__LINE__##*\}\!}"
				;;
			*) printf %s\\n "$__LINE__";;
		esac
	done
}
pp "$@"
