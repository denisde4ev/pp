#!/bin/sh

cd "${0%/*}" || exit

t=$(mktemp)
trap 'rm -f "$t"' EXIT QUIT KILL
errs=0
for i in *.preprocess; do
	j=${i%.*}
	[ -f "$j" ] || {
		printf %s\\n "missing expected output file '$j' for file '$i'"
		exit 2
	}

	../pp "./$i" 2>/dev/null >"$t"
	case $i in
		status=${?}__*) ;;
		*)
			printf %s\\n "file '$i' got not epected exit status code: $?"
			diff -q "$t" "$j" || {
				printf %s\\n "file: '$i' is not as expected"
			}
			continue
		;;
	esac
	diff "$t" "$j" || {
		printf %s\\n "file: '$i' is not as expected"
		: $(( errs = errs + 1 ))
	}
done

case $errs in 0) printf %s\\n "no errors"; exit; esac

printf %s\\n "errors count: $errs"
exit 1
