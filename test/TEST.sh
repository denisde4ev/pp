#!/bin/sh
case $1 in -x) set -x; shift; esac


# todo:
# this is maybe not the best way to do tests
# 1 to 1 exact match means something that
# may vary for past/future decision have to be added to the tests.
# and if in future changed the thests must be updated with it.
# in other side this is great as input/output examples.

case $1 in --help) printf %s\\n "usage: $0 [test]..."; exit; esac

cd "${0%/*}" || exit

# config:
diff() {
	command diff --color=auto -u "$@"
}
pp_comm=../pp.preprocess




[ -x "$pp_comm" ] || {
printf %s\\n "please first build pp and enshure path is in '$PWD/$pp_comm' and can be executed by testing user"
exit 3
}
. "$pp_comm" # load pp as fn
case $(command -v pp) in pp) ;; *)
	printf %s\\n "failed to load pp as fn from sourcing: '$PWD/$pp_comm'"
	exit 3
esac

test0=$(echo '' | "$pp_comm") && case $test0 in ?*) false; esac || {
	printf %s\\n "test0 with empty input failed"
	exit 1
}

t=$(mktemp)
trap 'rm -f -- "$t"' EXIT QUIT KILL
errs=0
i_err=0
count=0
case $# in 0) set -- *.preprocess; esac
for i; do
	count=$(( count + 1 ))
	i_err=0
	j=${i%.*}
	[ -f "$j" ] || {
		printf %s\\n  >&2 "missing expected output file '$j' for file '$i'"
		exit 3
	}

	# pp as comm:
	case $i in
		status=0__*) "$pp_comm" "./$i" >"$t";;
		*)           "$pp_comm" "./$i" >"$t" 2>/dev/null;;
	esac

	case $i in status=${?}__*) ;; *)
		printf %s\\n  >&2 "file '$i' got not epected exit status code: $?"
		i_err=1
	esac

	diff "$t" "$j" || {
		printf %s\\n  >&2 "file: '$i' is not as expected" ""
		i_err=1
	}


	# pp as fn:
	case $i in
		status=0__*) pp "./$i" >"$t";;
		*)           pp "./$i" >"$t" 2>/dev/null;;
	esac

	case $i in status=${?}__*) ;; *)
		printf %s\\n  >&2 "[pp fn]: file '$i' got not epected exit status code: $?"
		i_err=1
	esac

	diff "$t" "$j" || {
		printf %s\\n  >&2 "[pp fn]: file: '$i' is not as expected" ""
		i_err=1
	}

	case $i_err in
		# 0) printf %s\\n "$i: ok"; git add "$i" "${i%.*}";;
		0) printf %s\\n "$i: ok";;
		*) printf %s\\n "$i: fail";;
	esac

	errs=$(( errs + i_err ))
done

case $errs in
	0) printf %s\\n >&2 "" "no errors";                  exit 0;;
	*) printf %s\\n >&2 "" "errors count: $errs/$count"; exit 1;;
esac
