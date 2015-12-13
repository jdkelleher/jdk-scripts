#!/bin/sh

# Create and manage rsync snapshots of a directory tree.

# This scripts is based on the work of Mike Rubel, Andrew J. Nelson, and rabraham.


# Change Log
#
# 2015-12-12 - JDK - Genesis...


# Functions
usage() {
	echo "Usage: $0 [-h -q -v -n] [-l <log>] [-i <N>] -s <dir> -d <dir>"
	echo "\t-h\t\tthis help message"
	echo "\t-q\t\tpass --quiet flag to rsync"
	echo "\t-v\t\tpass --verbose flag to rsync"
	echo "\t-n\t\tpass --dry-run flag to rsync"
	echo "\t-l logfile\tlog to the specified file"
	echo "\t-i N\tkeep N snapshots"
	echo "\t-s src_dir\tsource directory"
	echo "\t-d dest_dir\tdestination directory"
}


# Initialize defaults
RSYNC_OPTIONS=""
LOG_FILE=""
SRC_DIR=""
DEST_DIR=""
EXIT_STATUS=0


while getopts "hqvnl:i:s:d:" opt; do
	case $opt in
		h )
			usage
			exit 1
			;;
		q )
			RSYNC_OPTIONS="$RSYNC_OPTIONS --quiet"
			;;
		v )
			RSYNC_OPTIONS="$RSYNC_OPTIONS --verbose"
			;;
		n )
			RSYNC_OPTIONS="$RSYNC_OPTIONS --dry-run"
			;;
		l )
			LOG_FILE=$OPTARG
			;;
		i )
			SNAP_COUNT=$OPTARG
			;;
		s )
			SRC_DIR=$OPTARG
			;;
		d )
			DEST_DIR=$OPTARG
			;;
		? )
			usage
			exit 1
			;;
	esac
done
shift $(($OPTIND - 1))


# Check ARGS
if [ $# -gt 0 ] ; then
	echo "Invalid arguments: $*"
	usage
	exit 1
fi
if [ ! -d $SRC_DIR ] ; then
	usage
	exit 1
fi
if [ ! -d $DEST_DIR ] ; then
	usage
	exit 1
fi
if [ ! $SNAP_COUNT -ge 0 2>/dev/null ] ; then
	echo $SNAP_COUNT
	usage
	exit 1
fi




echo "Done"
exit $EXIT_STATUS

