#! /bin/sh
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

usage() {
  cat <<EOT
usage: $0 item class code-sed doc-sed sources -- makeinfo-args...
EOT
}

if [ $# -le 4 ]; then
  usage
  exit 2
fi

item=$1
shift
codesexp="$1"
shift
docsexp=$1
shift

source=
while [ $# -ne 0 ]
do
	if [ "$1" = "--" ]; then
		shift
		break;
	fi
	source="$source $1"
	shift
done	

TEMPDIR=/tmp/mfck.$$
mkdir $TEMPDIR || exit 1
trap 'rm -rf $TEMPDIR' 1 2 13 15

ltrim_ws() {
	# NOTE: The brackets contain a space and a tab!
	sed 's/^[ 	][ 	]*//'
}	

sed -n "$codesexp" $source | ltrim_ws | sort | uniq > $TEMPDIR/src

$* | \
 sed -n '/^@macro/,/^@end macro/d;'"$docsexp" | ltrim_ws \
  | sort | uniq > $TEMPDIR/doc

join -v1 $TEMPDIR/src $TEMPDIR/doc > $TEMPDIR/src-doc
join -v2 $TEMPDIR/src $TEMPDIR/doc > $TEMPDIR/doc-src
(if [ -s $TEMPDIR/src-doc ]; then
   echo "Not documented $item:"
   cat $TEMPDIR/src-doc 
 fi
 if [ -s $TEMPDIR/doc-src ]; then
   echo "Non-existing $item:"
   cat $TEMPDIR/doc-src
 fi) > $TEMPDIR/report

if [ -s $TEMPDIR/report ]; then 
  cat $TEMPDIR/report
  rm -rf $TEMPDIR
  exit 1
else
  rm -rf $TEMPDIR
  exit 0
fi
