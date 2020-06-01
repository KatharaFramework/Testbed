#!/bin/bash

set -e
# set -x

usage()
{
	echo "usage: test.sh [[-d n_devices] | [-h]]"
}

test()
{
	for (( i=1; i<=$n_routers; i++ ))
	do
		echo ""
		echo "Testing lab with $i routers..."

		mkdir -p labs/lab_$i

		touch labs/lab_$i/lab.conf

		if [ $i -gt 1 ]
		then
			echo "pc1:pc2" >> labs/lab_$i/lab.dep
		fi

		for (( j=1; j<=$i; j++ ))
		do
			echo "pc$j[0]=A" >> labs/lab_$i/lab.conf
		done


		cd labs/lab_$i
		/usr/bin/time -o time_start.txt -p kathara lstart

		/usr/bin/time -o time_clean.txt -p kathara lclean

		cd ../..
	done

	echo ""
	echo "Done."
}


n_routers=""

while [ "$1" != "" ]; do
	case $1 in
		-d | --devices )        shift
								n_routers=$1
								;;
		-h | --help )           usage
								exit
								;;
		* )                     usage
								exit 1
	esac
	shift
done

if [ "$n_routers" != "" ]
then
	test
else
	usage
fi