#!/bin/sh


# Defaults
DIRECTORIES='/home/kelleher/'

echo "Starting at `date`."
echo " "


#    --delete \
#    --delete-excluded \
#    --exclude 'media/music/*' \
#    --exclude 'media/non-music/*' \

rsync -av \
    --stats \
    --bwlimit=768 \
    --rsh="ssh -c arcfour -o Compression=no -x" \
    --rsync-path=/usr/bin/rsync \
    --sparse \
    --hard-links \
    --compress \
    --partial \
    --delete \
    --delete-excluded \
    --exclude 'media/music-old/*' \
    --exclude 'kio_http/cache/' \
    --exclude '.netscape/cache/' \
    --exclude '.mozilla/*/*/Cache/' \
    --exclude '.firefox/*/*/Cache/' \
    --exclude '.opera/cache*/' \
    --exclude '.thumbnails/*' \
    --exclude 'beth/the_L_word/*' \
    ${DIRECTORIES} \
    kelleher@jason.udlug.org:stripped-storage/home_kelleher_backup/

echo " "
echo "Ending at `date`."

