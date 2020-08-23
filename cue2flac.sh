#!/bin/sh

# Depends on shntools and cuetools for utilities and other packages for some codecs
#	sudo add-apt-repository ppa:flacon/ppa ; sudo apt-get update
# 	sudo aptitude install cuetools shntool flac flacon wavpack
# 

# TODO...
#	add usage message
#	add options
#	make a lot friendlier
#	check for dependencies
#	error checking would be nice...


#TEMP_DIR=wd.$$
TEMP_DIR=/tmp/wd.$$	# handy when /tmp is tmpfs, especially when the source files are on NFS - could check and set dynamically

for CUE_FILE in *.cue ; do

	# determine audio the audio file/format to split - only looking for the common ones, not everything supported by shntool
	for SUFFIX in ape flac wav wv tak ; do
		AUDIO_FILE=`echo ${CUE_FILE} | sed -e "s/\.cue/.${SUFFIX}/;"`
		if [ -f "${AUDIO_FILE}" ] ; then
			break
		fi
		# there should really be error checking here :shrug:
	done

	echo "Splitting..."
	echo "\t\"${CUE_FILE}\""
	echo "\t\"${AUDIO_FILE}\""


	# first, create a temp dir to work within - makes the tagging step easy
	mkdir -p ${TEMP_DIR}

	# second, split into ${TEMP_DIR}
	shnsplit -f "${CUE_FILE}" -d ${TEMP_DIR} -o flac -t "%n - %t" "${AUDIO_FILE}"

	# third, tag in ${TEMP_DIR}
	cuetag "${CUE_FILE}" ${TEMP_DIR}/*

	# fourth, move files out of ${TEMP_DIR}
	mv ${TEMP_DIR}/* .

	# lastly, cleanup
	rmdir ${TEMP_DIR}

done


