#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/syno/sbin:/usr/syno/bin:/usr/local/sbin:/usr/local/bin

BTRFS_VOLS=`mount | grep btrfs | awk '{print $1}'`

for FS in $BTRFS_VOLS; do

	# skip if snapshots exist

	# defrag

done

