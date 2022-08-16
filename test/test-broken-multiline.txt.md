$ pp test-broken-multiline.txt.pp `EXECUTED COMMAND`
!# this is line is will leave ` WRITTEN TO STDOUT`

123 `WRITTEN TO TTY`

Error: expected line that matches '!!*' but got end of file instead `WRITTEN TO STDERR`
$ echo $?
5 `EXIT CODE`
