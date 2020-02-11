# This file is part of GNU cflow
# Copyright (C) 2005-2019 Free Software Foundation, Inc.
#
# Written by Sergey Poznyakoff
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

AC_PREREQ(2.63)
AC_INIT([GNU cflow], [1.6], [bug-cflow@gnu.org])
AC_CONFIG_SRCDIR([src/cflow.h])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([1.11 gnits tar-ustar dist-bzip2 dist-xz std-options
silent-rules])
AC_CONFIG_HEADER([config.h])

# Enable silent rules by default:
AM_SILENT_RULES([yes])

gl_EARLY

# Checks for programs.
AC_PROG_CC
AC_PROG_LEX
AC_PROG_RANLIB

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h string.h unistd.h locale.h])

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE
AC_CHECK_FUNCS([memmove memset strdup strerror strtol setlocale])

gl_INIT
MU_DEBUG_MODE

### Check for Emacs site-lisp directory
AM_PATH_LISPDIR

if test "$EMACS" != "no"; then
	lisp_LISP='$(LISPSRC)'
fi
AC_SUBST(lisp_LISP)

# Gettext.
AM_ICONV
AM_GNU_GETTEXT([external], [need-formatstring-macros])
AM_GNU_GETTEXT_VERSION(0.17)

IMPRIMATUR_INIT(doc/imprimatur)

### Initialize the test suite.
AC_CONFIG_TESTDIR(tests)
AC_CONFIG_FILES([tests/Makefile tests/atlocal])
AM_MISSING_PROG([AUTOM4TE], [autom4te])

AC_CONFIG_FILES([
 Makefile
 gnu/Makefile
 src/Makefile
 elisp/Makefile
 po/Makefile.in 
 doc/Makefile])
AC_OUTPUT
