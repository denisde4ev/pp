#!/bin/sh
case $1 in -x) set -x; shift; esac
cd "${0%%/*}" || exit
set -eu


PREFIX=${PREFIX:-/usr/local}
USR_BIN=$PREFIX'/bin'
USR_MAN=$PREFIX'/share/man/man1'

rm -vf -- "$USR_BIN/pp"
install -Dm755 -- ./pp "$USR_BIN/pp"


case ${1-} in --no-doc) ;; *)
	rm -vf -- "$USR_MAN/pp.1"
	install -Dm644 -- ./pp.1 "$USR_MAN/pp.1"
esac
