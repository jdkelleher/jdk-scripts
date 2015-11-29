#!/bin/sh

usage() {
	printf "%s <90|180|270> file1 [file2 ...]\n" `basename $0`
}

ROTATION=$1

case $ROTATION in
	90|180|270)
	shift
	;;
	*)
	usage
	exit 1
	;;
esac

if [ $# -lt 1 ]; then
	usage
fi

TMP_FILE="/tmp/`basename $0`-$$.JPEG"

for FILE in "$@" ; do
	if [ "`identify -format '%m' "$FILE"`" != "JPEG" ]; then
		printf "Warning: File \"%s\" is not a JPEG!  Skipping it.\n" "$FILE"
		continue
	fi
	printf "Rotating \"%s\" %d degrees... " "$FILE" $ROTATION
	jpegtran -rotate $ROTATION -copy all "$FILE" > "$TMP_FILE"
	if [ $? -ne 0 ]; then
		printf "\nWarning: Error rotating \"%s\".  Skipping it.\n" "$FILE"
		rm "$TMP_FILE"
	else
		cp "$TMP_FILE" "$FILE"
		rm "$TMP_FILE"
		printf "done.\n"
	fi
done

