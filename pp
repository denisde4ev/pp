#!/bin/sh

_die_() {
	printf %s\\n >&2 "Error: $1"
	exit "${2-2}"
}

case $1 in
--help)
	printf %s\\n \
		"Usage: ${0##*/} v0.3.1(denisde4ev)" \
		"  * STDIN | ${0##*/} > output -- See pp(1) for details and examples" \
		"Syntax:" \
		"  * Lines beginning !! are replaced with the following text evaluated" \
		"      as a shell command." \
		"  * Lines beginning !| are for multiline evaluation" \
		"      lines are parsed untill find line begining with !!" \
		"  * Lines beginning || are replaced with the following text" \
		"      without any modifications" \
		"  * Section !{...}! on one __LINE__ is replaced by the output of cmd '...'" \
		"  * Variables to use: \$__LINE_NUMBER__ for line no. \$__LINE__ for line itself" \
	;
	exit
	;;
-*)
	_die_ "see --help for usage"
esac

# hope eval wont chane it
NEW_LINE='
'

_readline_() {
	IFS= read -r __LINE__ || {
		case $__LINE__ in
			'') return $?;;
			?*) __pp_eof__='';;
		esac
	}
}

case ${ASH_VERSION+x}${ZSH_VERSION+x}${BASH_VERSION+x} in
*x*)
	eval "_escape_() { printf %s\\\\n \"${1//\\'/\\'\\\\\\'\\'}\"; }"
	;;
*)
	_escape_() {
		case $1 in
			*"'"*) printf %s "$1" | sed "s/'/'\\\\''/g; 1 s/^/'/; $ s/$/' /";;
			*) printf %s "'$1'";;
		esac
	}

esac

_pp_() {
	while _readline_; do
		__LINE_NUMBER__=$((__LINE_NUMBER__+1))
		case $__LINE__ in
			!!|!!#*|'!! #'*|'!!	#'*) # fully ignore lines that contains only a comment
			;;
			!!*)
				eval "${__LINE__##!!}" || {
					_die_ "LINE $__LINE_NUMBER__: evaluation error $?" 3
				}
			;;
			\|\|*) printf %s${__pp_eof__:-\\n} "${__LINE__#??}";;
			!\|*)
				__PREVLINES__=${__LINE__#??}
				while :; do
					_readline_ || {
						_die_ "expected line that matches '!!*' but got end of file instead" 5
					}
					case $__LINE__ in
						#!||!|#*|'!| #'*|'!|	#'*)
							# DONT: DETECT IF LINE IS A COMMENT:
							# it might not be a coment, but to be a continuation from previous line,
							# for example here document and/or unclosed quote,
							# insane example:
							# ``` sh
							# $ ( sed 's/-/--/g' << '#'EOF; tr - _ << \#EOF2; echo "echo-line:1
							# > #echo-line:2" )
							# > #here-document-for-sed
							# > #EOF
							# > #here-document-for-tr
							# > #EOF2
							# ```
							# ``` sh.output
							# #shere--document--for--sed
							# #here_document_for_tr
							# echo-line:1
							# #echo-line:2
							# ```
						#;;

						!\|*) __PREVLINES__=$__PREVLINES__$NEW_LINE${__LINE__##??};;
						!!*)
							eval "$__PREVLINES__$NEW_LINE${__LINE__##??}" || {
								_die_ "LINES $__LINE_NUMBER__: evaluation error $?" 3
							}
							break
						;;
						\|\|*) # nested lin that is trimmed from start, note/TODO:  is not interpreted here
							__pp_tmp__=${__LINE__#??}
							__pp_tmp__=${__pp_tmp__#"${__pp_tmp__%%[!" 	"]*}"}
							__PREVLINES__=$__PREVLINES__$NEW_LINE"printf %s\\\\n $(_escape_ "${__pp_tmp__}")"
						;;
						*) __PREVLINES__=$__PREVLINES__$NEW_LINE"printf %s\\\\n $(_escape_ "$__LINE__")";;
					esac
				done
				unset __PREVLINES__
			;;
			*!\{*\}!*)
				__pp_tmp__=${__LINE__#*\!{}
				__pp_tmp__=$(eval "${__pp_tmp__%\}\!*}") || {
					_die_ "Line $__LINE_NUMBER__: section evaluation error $?" 3
				}
				printf %s%s%s${__pp_eof__:-\\n} \
					"${__LINE__%%\!{*}" \
					"$__pp_tmp__" \
					"${__LINE__##*\}\!}"
				;;
			*)
				printf %s${__pp_eof__:-\\n} "$__LINE__"
			;;
		esac
	done
}

__PP_LVL__=0
pp() {
	__PP_LVL__=$((__PP_LVL__+1)) # allow included scripts to detect included file level
	case $1 in
		--) shift;;
		-) ;;
		-*) _die_ "No arguments are taken";;
	esac
	case $# in 0) set -- -; esac
	for __FILE__; do
		case $__FILE__ in
			-) _pp_;;
			*) _pp_ < "$__FILE__";;
		esac
	done
}

pp "$@"
