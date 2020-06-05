#!/bin/bash

set -e

usage()
{
	echo "usage: test.sh [[-d n_devices] | [-h]]"
}

test()
{
	for (( i=1; i<=$n_devices; i++ ))
	do
		echo "Testing lab with $i devices..."

		mkdir -p labs/lab_$i

		if [ $i -gt 1 ]
		then
			mkdir -p labs/lab_$i/image
			cp image/dind-kathara.tar labs/lab_$i/image/dind-kathara.tar
			cp -r shared/ labs/lab_$i/

			echo "pc1[0]=\"A\"" >> labs/lab_$i/lab.conf
			echo "pc1[image]=\"kathara/dind\"" >> labs/lab_$i/lab.conf

			currPath="labs/lab_$i/pc1/sublab"

			for (( j=2; j<$i; j++ ))
			do
				mkdir -p $currPath
				echo "pc1[0]=\"A\"" >> $currPath/lab.conf
				echo "pc1[image]=\"kathara/dind\"" >> $currPath/lab.conf
				currPath="$currPath/pc1/sublab"
			done

			mkdir -p $currPath
			cp -R lab/. $currPath
		else
			cp -R lab/. labs/lab_$i
		fi

		cd labs/lab_$i

		/usr/bin/time -o time_start.txt -p kathara lstart --privileged
		/usr/bin/time -o time_clean.txt -p kathara lclean

		cd ../..
		echo ""
	done

	echo "Done."
}


n_devices=""

while [ "$1" != "" ]; do
	case $1 in
		-d | --devices )        shift
								n_devices=$1
								;;
		-h | --help )           usage
								exit
								;;
		* )                     usage
								exit 1
	esac
	shift
done

if [ "$n_devices" != "" ]
then
	test
else
	usage
fi