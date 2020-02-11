# This file is part of Imprimatur.
# Copyright (C) 2006, 2007, 2010, 2011 Sergey Poznyakoff
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

imprimatur-format:
	@if test -n "`cat $(imprimatur_INPUT) | tr -d -c '\t'`"; then \
		echo "Sources contain tabs; run make imprimatur-untabify"; \
		false; \
	fi

imprimatur-refs:
	@for file in $(imprimatur_INPUT); \
	do \
          grep -q '^@c imprimatur-ignore' $$file && continue; \
	  sed -e = $$file | \
           sed -n 'N;/@FIXME-.*ref/{s/\(^[0-9][0-9]*\).*@FIXME-.*ref{\([^}]*\)}.*/'$$file':\1: \2/gp}'; \
	done > $@-t; \
	if [ -s $@-t ]; then \
	  echo "Unresolved cross-references:"; \
	  cat $@-t;\
	  rm $@-t; \
	else \
	  rm -f $@-t; \
	fi

imprimatur-fixmes:
	@for file in $(imprimatur_INPUT); \
	do \
          grep -q '^@c imprimatur-ignore' $$file && continue; \
	  sed -e = $$file | \
           sed -n 'N;/@FIXME{/{s/\(^[0-9][0-9]*\).*@FIXME{\([^}]*\).*/'$$file':\1: \2/gp}'; \
	done > $@-t; \
	if [ -s $@-t ]; then \
	  echo "Unresolved FIXMEs:"; \
	  cat $@-t; \
	  rm $@-t; \
	  false; \
	else \
          rm -f $@-t; \
	fi

imprimatur-writemes:
	@files=`grep -c '^@c imprimatur-ignore' $(imprimatur_INPUT) | sed -n 's/:0$$//p'`; \
	test -n "$$files" && grep -Hn '^[ \t]*@WRITEME' $$files > $@-t; \
	if [ -s $@-t ]; then \
	  echo "Empty nodes:"; \
	  cat $@-t; \
	  rm $@-t; \
	  false;\
	else \
	   rm $@-t; \
	fi

imprimatur-empty-nodes:
	@awk -f $(top_srcdir)/$(IMPRIMATUR_MODULE_DIR)/emptynodes.awk \
         -v scriptname=$(top_srcdir)/$(IMPRIMATUR_MODULE_DIR)/emptynodes.awk \
         -v makeinfoflags="$(AM_MAKEINFOFLAGS) $(MAKEINFOFLAGS)" \
	        $(info_TEXINFOS)

imprimatur-unrevised:
	@files=`grep -c '^@c imprimatur-ignore' $(imprimatur_INPUT) | sed -n 's/:0$$//p'`; \
	grep -Hn '^[ \t]*@UNREVISED' $$files > $@-t; \
	if [ -s $@-t ]; then \
	  echo "Unrevised nodes:"; \
	  cat $@-t; \
	  rm $@-t; \
	  false;\
	else \
          rm $@-t; \
	fi

if IMPRIMATUR_COND_FRENCHSPACING
imprimatur-check-sentence-spacing:
	@if grep -q '\.  [@A-Z]' $(imprimatur_INPUT); then \
	   echo >&2 "Sources contain double-space sentence separators."; \
	   echo >&2 "Run make imprimatur-fix-sentence-spacing to fix."; \
	fi

imprimatur-fix-sentence-spacing:
	@for file in $(imprimatur_INPUT); \
	do \
	  if grep -q '\.  [@A-Z]' $$file; then \
	    mv $$file $${file}~; \
	    sed -r 's/\.  ([@A-Z])/. \1/g' $${file}~ > $$file; \
	  fi; \
	done
else
imprimatur-check-sentence-spacing:
	@if grep -q '\. [@A-Z]' $(imprimatur_INPUT); then \
		echo >&2 "Sources contain single-space sentence separators."; \
		echo >&2 "Run make imprimatur-fix-sentence-spacing to fix."; \
	fi

imprimatur-fix-sentence-spacing:
	@for file in $(imprimatur_INPUT); \
	do \
	  if grep -q '\. [@A-Z]' $$file; then \
	    mv $$file $${file}~; \
	    sed -r 's/\. ([@A-Z])/.  \1/g' $${file}~ > $$file; \
	  fi; \
	done
endif


imprimatur-basic-checks: imprimatur-format imprimatur-check-sentence-spacing \
                 imprimatur-refs imprimatur-fixmes \
                 imprimatur-empty-nodes imprimatur-unrevised

imprimatur-master-menu:
	@emacs -batch -l $(top_srcdir)/$(IMPRIMATUR_MODULE_DIR)/mastermenu.el \
               -f make-master-menu $(info_TEXINFOS)

imprimatur-untabify:
	@emacs -batch -l $(top_srcdir)/$(IMPRIMATUR_MODULE_DIR)/untabify.el \
               $(imprimatur_INPUT)

imprimatur-final: imprimatur-untabify imprimatur-master-menu


