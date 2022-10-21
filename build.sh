#!/bin/sh
case $1 in -x) set -x; shift; esac
cd "${0%%/*}" || exit
set -eu


VERSION=$(git describe --long) 2>/dev/null && VERSION=$(printf %s\\n "$VERSION" | sed 's/\([^-]*-\)g/r\1/;s/-/./g') || \
VERSION=r$(git rev-list --count HEAD).$(git rev-parse --short HEAD) || \
exit

export VERSION=${VERSION:?}
./pp.preprocess ./pp.preprocess > ./pp


case ${1-} in --no-doc) ;; *)
	pandoc --standalone ./pp.1.md --to man  > ./pp.1
esac
