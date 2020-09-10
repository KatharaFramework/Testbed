#!/bin/bash

set -e

usage()
{
	echo "usage: test.sh [[-d n_devices] [-n n_brothers] | [-h]]"
}

test()
{
	for (( i=1; i<=$n_devices; i++ ))
	do
		echo "Testing lab with $i devices..."

		mkdir -p labs/lab_$i/image
		cp image/dind-kathara.tar labs/lab_$i/image/dind-kathara.tar
		cp -r shared/ labs/lab_$i/

		currPath="labs/lab_$i"

		for (( j=0; j<=$(($i-1)); j++ ))
		do
			echo "pc$((j%n_brothers))[0]=\"A\"" >> $currPath/lab.conf
			echo "pc$((j%n_brothers))[image]=\"kathara/dind\"" >> $currPath/lab.conf

			if [ $(((j+1)%n_brothers)) -eq 0 ] && [ $j -gt 0 ]
			then
				currPath="$currPath/pc0/sublab"
				mkdir -p $currPath
			fi
		done

		cd labs/lab_$i

		/usr/bin/time -o time_start.txt -p kathara lstart --privileged
		/usr/bin/time -o time_clean.txt -p kathara lclean

		cd ../..
		echo ""
	done

	echo "Done."
}


n_devices=""
n_brothers=2

while [ "$1" != "" ]; do
	case $1 in
		-d | --devices )        shift
								n_devices=$1
								;;
		-n | --brothers )        shift
								n_brothers=$1
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