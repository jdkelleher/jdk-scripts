#!/bin/sh


# Defaults
DIRECTORIES='/home/kelleher/'

echo "Starting at `date`."
echo " "


#    --delete \
#    --delete-excluded \
#    --exclude 'media/music/*' \
#    --exclude 'media/non-music/*' \

rsync -avHSz \
    --stats \
    --bwlimit=768 \
    --rsh="ssh -c blowfish" \
    --rsync-path=/usr/bin/rsync \
    --size-only \
    --delete \
    --delete-excluded \
    --exclude 'media/music-old/*' \
    --exclude 'kio_http/cache/' \
    --exclude '.netscape/cache/' \
    --exclude '.mozilla/*/*/Cache/' \
    --exclude '.firefox/*/*/Cache/' \
    --exclude '.opera/cache*/' \
    --exclude 'beth/the_L_word/*' \
    ${DIRECTORIES} \
    kelleher@venus.ruddy.net:stripped-storage/home_kelleher_backup/

echo " "
echo "Ending at `date`."

