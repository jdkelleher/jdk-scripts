#!/bin/sh

last=$(eval "echo \$$#")
echo $last
echo $*

while [ $# -gt 1 ] ; do
	list="$list $1"
	shift
done
last=$1
echo $last
echo $list



