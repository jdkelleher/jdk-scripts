#!/bin/sh


PREFIX=$1

PAD=$2

MAX=$3


echo "Use fixed PAD"
i=0
while [ $i -le $MAX ] ; do

	OUTPUT=`printf "${PREFIX}.%0${PAD}d\n" $i`

	echo $OUTPUT

	i=`expr $i + 10`

done


echo "Use calculated PAD"
if [ $MAX -lt 100 ] ; then
	PAD=2
elif [ $MAX -lt 1000 ] ; then
	PAD=3
elif [ $MAX -lt 10000 ] ; then
	PAD=4
fi

i=0
while [ $i -le $MAX ] ; do

	OUTPUT=`printf "${PREFIX}.%0${PAD}d\n" $i`

	echo $OUTPUT

	i=`expr $i + 10`

done

