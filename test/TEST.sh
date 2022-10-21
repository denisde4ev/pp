#!/bin/sh

diff() {
	command diff --color=auto -u "$@"
}
pp_comm=../pp.preprocess



cd "${0%/*}" || exit

[ -x "$pp_comm" ] || {
printf %s\\n "please first build pp and enshure path is in '$PWD/$pp_comm' and can be executed by testing user"
exit 3
}

test0=$(echo '' | "$pp_comm") && case $test0 in ?*) false; esac || {
	printf %s\\n "test0 with empty input failed"
	exit 1
}

t=$(mktemp)
trap 'rm -f -- "$t"' EXIT QUIT KILL
errs=0
i_err=0
count=0
for i in *.preprocess; do
	count=$(( count + 1 ))
	i_err=0
	j=${i%.*}
	[ -f "$j" ] || {
		printf %s\\n  >&2 "missing expected output file '$j' for file '$i'"
		exit 3
	}

	case $i in
		status=0__*) "$pp_comm" "./$i"  >"$t";;
		*) "$pp_comm" "./$i" 2>/dev/null >"$t";;
	esac

	case $i in status=${?}__*) ;; *)
		i_err=1
		printf %s\\n  >&2 "file '$i' got not epected exit status code: $?"
	esac

	diff "$t" "$j" || {
		printf %s\\n  >&2 "file: '$i' is not as expected" ""
		i_err=1
	}
	case $i_err in
		0) printf %s\\n "$i: ok";;
		*) printf %s\\n "$i: fail";;
	esac

	errs=$(( errs + i_err ))
done

case $errs in
	0) printf %s\\n >&2 "" "no errors";                  exit 0;;
	*) printf %s\\n >&2 "" "errors count: $errs/$count"; exit 1;;
esac
