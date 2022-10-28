
* pp now can be build using `VERSION=v0.3.2 ./pp.preprocess ./pp.preprocess > ./pp` (just updates the version) https://github.com/denisde4ev/pp/commit/2bc1a58bfc9320052c306cb9af304ba683183704
* rename var: '__LINES__' -> '__PREVLINES__' when parsing `!| ...` lines https://github.com/denisde4ev/pp/commit/3ccf49fa2a194273ad9c919acc4f7546f6054d43
* mostly fix all error handling for evaluation https://github.com/denisde4ev/pp/commit/3ccf49fa2a194273ad9c919acc4f7546f6054d43
* fix line count for error message + more verbose error message https://github.com/denisde4ev/pp/commit/8d00c3a48a68751d515d74833d87ed5a98b07fe8
* support '--' as end of args https://github.com/denisde4ev/pp/commit/b8583d721f9be87807c93f3f2cf921453ea3c241
* fixed some small bugs (dir as arg, lost exit status)

---- Time of last modification:2022-10-21 16:42:04.408847000 +0300 ----
