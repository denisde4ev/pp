#!/bin/sh

cd "${0%/*}" || exit

NODOC=1  ./pp.preprocess ./PKGBUILD.preprocess | tee PKGBUILD
