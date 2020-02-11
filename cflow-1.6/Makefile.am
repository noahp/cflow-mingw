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

ACLOCAL_AMFLAGS = -I m4 -I doc/imprimatur

SUBDIRS = gnu src elisp po doc tests

EXTRA_DIST = ChangeLog.2007

# Define the following variables in order to use the ChangeLog rule below:
#  prev_change_log  [optional]  Name of the previous ChangeLog file.
#  gen_start_date   [optional]  Start ChangeLog from this date. 
#  changelog_dir    [mandatory] Directory where to create ChangeLog
gen_start_date = 2007-06-29
prev_change_log = ChangeLog.2007
changelog_dir = .

.PHONY: ChangeLog
ChangeLog: 
	if test -d .git; then                                              \
	  cmd=$(top_srcdir)/build-aux/gitlog-to-changelog;                 \
	  if test -n "$(gen_start_date)"; then                             \
	    cmd="$$cmd --since=\"$(gen_start_date)\"";                     \
	  fi;                                                              \
	  $$cmd |                                                          \
            sed '/<unknown>$$/d' | fmt -s > $(changelog_dir)/cl-t;         \
          if test -n "$(prev_change_log)" && test -f "$(prev_change_log)"; \
	  then                                                             \
	    echo "" >> $(changelog_dir)/cl-t;                              \
	    cat "$(prev_change_log)" |                                     \
	      sed '/^Local Variables:/,/^End:/d' >> $(changelog_dir)/cl-t; \
	  fi;                                                              \
	  echo "Local Variables:" >> $(changelog_dir)/cl-t;                \
	  echo "mode: change-log" >> $(changelog_dir)/cl-t;                \
	  echo "version-control: never"  >> $(changelog_dir)/cl-t;         \
	  echo "buffer-read-only: t" >> $(changelog_dir)/cl-t;             \
	  echo "End:" >> $(changelog_dir)/cl-t;                            \
	  rm -f $(changelog_dir)/ChangeLog;                                \
	  mv $(changelog_dir)/cl-t $(changelog_dir)/ChangeLog;             \
	fi

alpha:
	$(MAKE) dist distdir=$(PACKAGE)-$(VERSION)-`date +"%Y%m%d"`

alphacheck:
	$(MAKE) distcheck distdir=$(PACKAGE)-$(VERSION)-`date +"%Y%m%d"`
