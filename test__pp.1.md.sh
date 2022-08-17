#!/bin/sh

cd "${0%/*}" || exit
exec pandoc --standalone ./pp.1.md --to man | man /dev/stdin
# and human decides this test
