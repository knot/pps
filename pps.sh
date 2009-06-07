#!/bin/bash

#
# This file is part of the pps project.
#
# Copyright (C) 2009 Petr Uzel <petr.uzel@centrum.cz>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#

function print_help() {
cat << EOF
Usage: pps.sh [OPTIONS]
In a directory with a specfile and tarball with sources, prepare the sources
for future work. This may involve running 'quilt setup', pushing the patches,
generating ctags and/or cscope databases, etc.

OPTIONS:
	-h 				print this help

Report bugs to <petr.uzel@centrum.cz>
EOF
}

# process arguments
while getopts ":h" option
do
	case $option in
		h) print_help;
		   exit 0;;
		*) echo "pps.sh: invalid option -- 'TODO'";
		   echo "Try 'pps.sh -h' for more information";
		   exit 1;
   esac
done



# check specfile
spec_file_count=$(ls -1 *.spec 2>/dev/null | wc -l)

if [ $spec_file_count -ne 1 ]; then
	echo "Error: no specfile found";
	exit 1;
fi;

specfile=*.spec

# check for existence of needed utilities
# check if quilt is installed
if ! which quilt > /dev/null ; then
	echo "Error: quilt is not installed";
	exit 1;
fi;

# check if extracted tarball exists
#TODO

# quilt setup on specfile
#TODO quilt returns 0 even if the prep section failed
#if ! quilt setup $specfile; then
#	echo "Error: quilt setup failed";
#	echo 1;
#fi;

quilt_output=$(mktemp /tmp/pps-qso.XXXXXX)

quilt setup $specfile > $quilt_output 2>&1

#TODO check quilt_output for errors

# get name of the directory with sources
archives=$(grep '^Unpacking archive' $quilt_output | sed 's/^Unpacking archive \(.*\)/\1/')
archives_count=$(echo $archives | wc -w)

if [ $archives_count -eq 0 ]; then
	echo "Error: it seems that no archive was unpacked - strange";
	exit 1;
fi;

if [ $archives_count -ge 2 ]; then
	echo "Error: more than one archive was unpacked - this is not supported (yet)";
	exit 1;
fi;

top_dirs_count=$(tar tf $archives | cut -d '/' -f 1 | sort -u | wc -l)
if [ $top_dirs_count -gt 1 ]; then
	echo "Error: source tarball contains more than one top-level directory - this is not supported";
	exit 1;
fi;
src_directory=$(tar tf $archives | cut -d '/' -f 1 | sort -u)

# cd to uncompressed tarball
cd $src_directory

# quilt push -a
quilt push -a

# make ctags database
ctags -R --exclude=.pc .

#TODO: make cscope database

#TODO: set options for osc build (perhaps something like user-defined postscript ?)


#TODO accept -h (help)
#TODO accept -f (force)
#TODO accept -v (verbose)
#TODO delete temporary files (with traps?)
#TODO accept -n (no color)
#TODO accept -q (quiet)
#TODO rename pps.sh -> pps
#TODO describe default actions taken when no arguments are given
