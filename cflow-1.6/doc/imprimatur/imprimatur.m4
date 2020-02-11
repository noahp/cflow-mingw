# imprimatur.m4 serial 1
dnl This file is part of Imprimatur.
dnl Copyright (C) 2011 Sergey Poznyakoff
dnl
dnl Imprimatur is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 3, or (at your option)
dnl any later version.
dnl
dnl Imprimatur is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with Imprimatur.  If not, see <http://www.gnu.org/licenses/>.

dnl The option stuff below is based on the similar code from Automake

# _IMPRIMATUR_MANGLE_OPTION(NAME)
# -------------------------------
# Convert NAME to a valid m4 identifier, by replacing invalid characters
# with underscores, and prepend the _IMPRIMATUR_OPTION_ suffix to it.
AC_DEFUN([_IMPRIMATUR_MANGLE_OPTION],
[[_IMPRIMATUR_OPTION_]m4_bpatsubst($1, [[^a-zA-Z0-9_]], [_])])

# _IMPRIMATUR_SET_OPTION(NAME)
# ----------------------------
# Set option NAME.  If NAME begins with a digit, treat it as a requested
# Guile version number, and define _IMPRIMATUR_GUILE_VERSION to that number.
# Otherwise, define the option using _IMPRIMATUR_MANGLE_OPTION.
AC_DEFUN([_IMPRIMATUR_SET_OPTION],
[m4_if(m4_bpatsubst($1,^[[0-9]].*,[]),,[m4_define([_IMPRIMATUR_GUILE_VERSION],[$1])],[m4_define(_IMPRIMATUR_MANGLE_OPTION([$1]), 1)])])

# _IMPRIMATUR_IF_OPTION_SET(NAME,IF-SET,IF-NOT-SET)
# -------------------------------------------------
# Check if option NAME is set.
AC_DEFUN([_IMPRIMATUR_IF_OPTION_SET],
[m4_ifset(_IMPRIMATUR_MANGLE_OPTION([$1]),[$2],[$3])])

# _IMPRIMATUR_OPTION_SWITCH(NAME1,IF-SET1,[NAME2,IF-SET2,[...]],[IF-NOT-SET])
# ---------------------------------------------------------------------------
# If NAME1 is set, run IF-SET1.  Otherwise, if NAME2 is set, run IF-SET2.
# Continue the process for all name-if-set pairs within [...].  If none
# of the options is set, run IF-NOT-SET.
AC_DEFUN([_IMPRIMATUR_OPTION_SWITCH],
[m4_if([$4],,[_IMPRIMATUR_IF_OPTION_SET($@)],dnl
[$3],,[_IMPRIMATUR_IF_OPTION_SET($@)],dnl
[_IMPRIMATUR_IF_OPTION_SET([$1],[$2],[_IMPRIMATUR_OPTION_SWITCH(m4_shift(m4_shift($@)))])])])

# _IMPRIMATUR_SET_OPTIONS(OPTIONS)
# --------------------------------
# OPTIONS is a space-separated list of IMPRIMATUR options.
AC_DEFUN([_IMPRIMATUR_SET_OPTIONS],
[m4_foreach_w([_IMPRIMATUR_Option], [$1], [_IMPRIMATUR_SET_OPTION(_IMPRIMATUR_Option)])])

# IMPRIMATUR_INIT([DIR],[OPTIONS])
# DIR       - Directory in the source tree where imprimatur has been cloned.
#             Default is "imptimatur".
# OPTIONS   - A whitespace-separated list of options.  Valid options are:
#             (1) any one of PROOF, DISTRIB or PUBLISH to set the default
#             rendition, (2) frenchspacing to declare that French sentence
#             spacing should be assumed, (3) makedoc to enable rules for
#             building imprimatur documentation, and (4) dist-info to
#             build and distribute imprimatur.info file (requires makedoc).
AC_DEFUN([IMPRIMATUR_INIT],[
 m4_pushdef([imprimaturdir],[m4_if([$1],,[imprimatur],[$1])])
 AC_SUBST([IMPRIMATUR_MODULE_DIR],imprimaturdir)
 _IMPRIMATUR_SET_OPTIONS([$2])
 AC_SUBST(RENDITION)
 _IMPRIMATUR_OPTION_SWITCH([PROOF],[RENDITION=PROOF],
                           [DISTRIB],[RENDITION=DISTRIB],
			   [PUBLISH],[RENDITION=PUBLISH],
			   [
  # Doc hints.
  # Select a rendition level:
  #  DISTRIB for stable releases (at most one dot in the version number)
  #  and maintenance releases (two dots, patchlevel < 50)
  #  PROOF for alpha releases.
  #  PUBLISH can only be required manually when running make in doc/
  case `echo $VERSION|sed  's/[[^.]]//g'` in
  ""|".")  RENDITION=DISTRIB;;
  "..")  if test `echo $VERSION | sed  's/.*\.//'` -lt 50; then
	   RENDITION=DISTRIB
         else
           RENDITION=PROOF
         fi;;
  *)     RENDITION=PROOF;;
  esac
 ])
 AC_SUBST([IMPRIMATUR_MAKEINFOFLAGS],
          ['-I $(top_srcdir)/imprimaturdir -D $(RENDITION)'])
 AM_CONDITIONAL([IMPRIMATUR_COND_MAKEDOC],dnl
                 [_IMPRIMATUR_IF_OPTION_SET([makedoc],[true],[false])])
 AM_CONDITIONAL([IMPRIMATUR_COND_FRENCHSPACING],
                 [_IMPRIMATUR_IF_OPTION_SET([frenchspacing],[true],[false])])
 AM_CONDITIONAL([IMPRIMATUR_COND_DIST_INFO],
                 [_IMPRIMATUR_IF_OPTION_SET([dist-info],[true],[false])])
 AC_CONFIG_FILES(imprimaturdir[/Makefile])		 
 AM_COND_IF([IMPRIMATUR_COND_MAKEDOC],dnl	 
            [AC_MSG_NOTICE([Add imprimaturdir[/Makedoc] to your config files])])
		 
 m4_popdef([imprimaturdir])
])
