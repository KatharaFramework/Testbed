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
		touch labs/lab_$i/lab.conf

		if [ $i -gt 1 ]
		then
			echo "pc1:pc2" >> labs/lab_$i/lab.dep
		fi

		for (( j=1; j<=$i; j++ ))
		do
			echo "pc$j[0]=\"A\"" >> labs/lab_$i/lab.conf
		done

		cd labs/lab_$i

		/usr/bin/time -o time_start.txt -p kathara lstart
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