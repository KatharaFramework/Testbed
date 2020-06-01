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

		mkdir -p labs/lab_$i/image

		cp image/dind-kathara.tar labs/lab_$i/image/dind-kathara.tar
		cp -r shared/ labs/lab_$i/

		echo "pc1[0]=A" >> labs/lab_$i/lab.conf
		echo "pc1[image]=kathara/dind" >> labs/lab_$i/lab.conf

		if [ $i -gt 1 ]
		then
			echo "pc2[0]=A" >> labs/lab_$i/lab.conf
			echo "pc2[image]=kathara/dind" >> labs/lab_$i/lab.conf
		fi

		currPath="labs/lab_$i/pc1/sublab"

		for (( j=3; j<=$i; j++ ))
		do
			mkdir -p $currPath

			if [ $((j%2)) -eq 0 ]
			then
				echo "pc2[0]=A" >> $currPath/lab.conf
				echo "pc2[image]=kathara/dind" >> $currPath/lab.conf
			else
				echo "pc1[0]=A" >> $currPath/lab.conf
				echo "pc1[image]=kathara/dind" >> $currPath/lab.conf
				currPath="$currPath/pc1/sublab"
			fi
		done


		cd labs/lab_$i
		/usr/bin/time -o time_start.txt -p kathara lstart --privileged

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