echo 1
!!#
!! echo echo 2
!!#
!| for i in 3 4 5; do
!|  echo echo $i
||      # line trimmed from start
        # line not trimmed from start
!|#
!! done
!!#
