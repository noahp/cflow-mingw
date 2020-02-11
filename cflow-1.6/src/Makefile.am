# This file is part of GNU cflow
# Copyright (C) 2005, 2007, 2009, 2016 Free Software Foundation, Inc.
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

bin_PROGRAMS = cflow
cflow_SOURCES = \
 c.l\
 cflow.h\
 depmap.c\
 gnu.c\
 linked-list.c\
 main.c\
 output.c\
 parser.c\
 parser.h\
 posix.c\
 rc.c\
 symbol.c\
 wordsplit.c\
 wordsplit.h

localedir = $(datadir)/locale

LDADD=../gnu/libgnu.a @LIBINTL@
AM_CPPFLAGS=\
 -I$(top_srcdir)/gnu -I../ -I../gnu\
 -DLOCALEDIR=\"$(localedir)\"
AM_LFLAGS=-dvp
EXTRA_DIST=cflow.rc

CFLOW=$(abs_builddir)/cflow
CFLOW_FLAGS=-i^s --brief
cflow_CFLOW_INPUT=$(cflow_OBJECTS:.@OBJEXT@=.c)
cflow.cflow: $(cflow_CFLOW_INPUT) cflow.rc Makefile
	$(AM_V_GEN)CFLOWRC=$(top_srcdir)/src/cflow.rc \
	 $(CFLOW) -ocflow.cflow --cpp="$(CC) -E" $(CFLOW_FLAGS) $(DEFS) \
                  $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) \
	          $(CPPFLAGS) \
         $(cflow_CFLOW_INPUT)
