#!/bin/sh

cd "${0%/*}" || exit

[ -x ../pp ] || {
printf %s\\n "please first build pp and enshure path is in '$PWD/pp' and can be executed by testing user"
exit 3
}

test0=$(echo '' | ../pp) && case $test0 in ?*) false; esac || {
	printf %s\\n "test0 with empty input failed"
	exit 1
}

t=$(mktemp)
trap 'rm -f -- "$t"' EXIT QUIT KILL
errs=0
count=0
for i in *.preprocess; do
	count=$(( count + 1))
	j=${i%.*}
	[ -f "$j" ] || {
		printf %s\\n "missing expected output file '$j' for file '$i'"
		exit 3
	}

	../pp "./$i" 2>/dev/null >"$t"
	case $i in
		status=${?}__*) ;;
		*)
			errs=$(( errs + 1 ))
			printf %s\\n "file '$i' got not epected exit status code: $?"
			diff -q "$t" "$j" || {
				printf %s\\n "file: '$i' is not as expected"
			}
			printf \\n
			continue
		;;
	esac
	diff "$t" "$j" || {
		printf %s\\n "file: '$i' is not as expected" ""
		errs=$(( errs + 1 ))
	}
done

case $errs in 0) printf %s\\n "no errors"; exit; esac

printf %s\\n "errors count: $errs/$count"
exit 1
