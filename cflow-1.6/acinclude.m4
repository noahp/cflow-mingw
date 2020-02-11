dnl This file is part of GNU mailutils.
dnl Copyright (C) 2001, 2016 Free Software Foundation, Inc.
dnl
dnl This file is free software; as a special exception the author gives
dnl unlimited permission to copy and/or distribute it, with or without
dnl modifications, as long as this notice is preserved.
dnl
dnl This program is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
dnl implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
dnl
dnl Check for --enable-debug switch. When the switch is specified, add
dnl -ggdb to CFLAGS and remove any optimization options from there.
dnl 

AC_DEFUN([MU_DEBUG_MODE],
  [AC_ARG_ENABLE(debug,                     
    [  --enable-debug          enable debugging mode],
    [if test x"$enableval" = xyes; then
       if test x"$GCC" = xyes; then
	 AC_MSG_CHECKING(whether gcc accepts -ggdb)
         save_CFLAGS=$CFLAGS
         CFLAGS="-ggdb -Wall"
         AC_TRY_COMPILE([],void f(){},
           AC_MSG_RESULT(yes),
           [if test x"$ac_cv_prog_cc_g" = xyes; then
              CFLAGS="-g -Wall"
            else
              CFLAGS=
            fi
            AC_MSG_RESULT(no)])
         CFLAGS="`echo $save_CFLAGS | sed 's/-O[[0-9]]//g'` $CFLAGS"
       fi
     fi])])
