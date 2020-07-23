#!/bin/sh

# this function is called when Ctrl-C is sent
trap_ctrlc() {
	# pring keep alive end time
	STOP_TSTAMP=`date`
	echo "\nEnding keep alive, ${STOP_TSTAMP}"

	# exit shell script with error code 0
	# if omitted, shell script will continue execution
	exit 0
}

# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2


# Begin main....

START_TSTAMP=`date`

echo "Starting keep alive, ${START_TSTAMP}"

while true; do
	echo -n "."
	sleep 60
done


