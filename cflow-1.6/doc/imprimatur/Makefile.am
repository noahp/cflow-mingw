# This file is part of Imprimatur.
# Copyright (C) 2011, 2015 Sergey Poznyakoff
#
# Imprimatur is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# Imprimatur is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Imprimatur.  If not, see <http://www.gnu.org/licenses/>.

EXTRA_DIST=\
 check-docs.sh\
 emptynodes.awk\
 imprimatur.m4\
 imprimatur.mk\
 mastermenu.el\
 rendition.texi\
 untabify.el

if IMPRIMATUR_COND_MAKEDOC
if IMPRIMATUR_COND_DIST_INFO
EXTRA_DIST += imprimatur.info
BUILT_SOURCES = imprimatur.info
endif
DISTCLEANFILES = Makedoc
MAKEDOC = $(MAKE) -f Makedoc
EXTRA_DIST += Makedoc.am Makedoc.in imprimatur.texi fdl.texi
.PHONY: imprimatur.info
imprimatur.info:; $(MAKEDOC)
info: imprimatur.info
pdf:; $(MAKEDOC) pdf
dvi:; $(MAKEDOC) dvi
ps:; $(MAKEDOC) ps
clean-local:; $(MAKEDOC) clean
endif
