#!/bin/sh 

usage() {
	printf "%s <x%%> file1 [file2 ...]\n" `basename $0`
}

#case $GEO in
#	25|45|75)
#	shift
#	;;
#	*)
#	usage
#	exit 1
#	;;
#esac

if [ $# -lt 2 ]; then
	usage
	exit 1
fi

GEO=$1
shift


for FILE in "$@" ; do
	printf "Resizing \"%s\" %s... " "$FILE" "$GEO"
	TMP_FILE="$FILE".$$
	convert "$FILE" -resize "$GEO" "$TMP_FILE"
	if [ $? -ne 0 ]; then
		printf "\n\tWarning: Error resizing \"%s\".  Skipping it.\n" "$FILE"
		# rm "$TMP_FILE"
	else
		cp "$TMP_FILE" "$FILE"
		rm "$TMP_FILE"
		printf "done.\n"
	fi
done

