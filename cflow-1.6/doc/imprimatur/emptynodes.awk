# This file is part of Imprimatur.
# Copyright (C) 2011 Sergey Poznyakoff
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

# State map:
# 0 - Initial
# 1 - Within @node
# 2 - Within @ignore
# 3 - Waiting for next @node
BEGIN {
	if (!includepath)
		includepath="."
	if (makeinfoflags) {
		n=split(makeinfoflags, flags)
		for (i = 1; i <= n; i++) {
			if (flags[i] == "-I")
				includepath = includepath " " flags[++i]
			else if (match(flags[i], /^-I(.+)/, dirs))
				 includepath = includepath " " dirs[1]
		}
	}
}

function report() {
	if (!nodes_reported) {
		print "Empty nodes:" > "/dev/stderr"
		nodes_reported = 1
	}
	if (node_locus)
		print node_locus ": " node_name > "/dev/stderr"
	else
		print FILENAME ":" FNR ": (unknown)" > "/dev/stderr"
}
skip_to && $1 == "@end" && $2 == skip_to { skip_to = ""; next }
skip_to { next }
/@c imprimatur-ignore/ { ignore = FILENAME }
ignore == FILENAME { next }
$1 == "@WRITEME" {
	node_locus=FILENAME ":" FNR
	node_name="(@WRITEME) " node_name
	report()
	state = 3
	next
}
$1 == "@bye" { state = 0; node_locus = "" }
$1 == "@macro" { skip_to = "macro"; next }
$1 == "@include" && scriptname {
	ofile = $2
	cmd = "find " includepath " -maxdepth 1 -name " ofile " -print -quit"
	$0=""
	cmd | getline
	close(cmd)
	file = $1
	if (!file) {
		print FILENAME ":" FNR ": cannot find file " ofile > "/dev/stderr"
		next
	}
	cmd = "awk -f " scriptname \
	      " -v scriptname=" scriptname \
	      " -v includepath='" includepath "'" \
	      " -v state=" state \
	      " -v nodes_reported=" (nodes_reported+0) \
	      " -v node_locus=\"" node_locus "\"" \
	      " -v node_name=\"" node_name "\"" \
	      " -v report_state=1 " file
	cmd | getline
	close(cmd)
	state = $1
	nodes_reported = $2
}	
$1 == "@node" {
	if (state == 1)
		report()
	sub(/@node[ \t][ \t]*/,"")
	node_name=$0
	node_locus=FILENAME ":" FNR
	state = 1
	next
}
state == 3 { next }
state == 0 { next }
state == 2 && /@end[ \t][ \t]*ignore/ { state = 1; next }
state == 2 { next }
/* Now in state 1: */
$1 == "@ignore" { state = 2; next }
$1 == "@printindex" { state = 3; next }
/^[ \t]*@/ || NF == 0 { next }
{ state = 3 }
END {
	if (report_state)
		print state,nodes_reported
	else {
		if (state == 1)
			report()
		exit(nodes_reported)
	}
}	