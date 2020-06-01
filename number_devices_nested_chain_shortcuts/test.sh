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
		echo "ifconfig 10.0.0.1/24 eth0 up" >> labs/lab_$i/pc1.startup

		currPath="labs/lab_$i"

		curName=""

		for (( j=1; j<=$i; j++ ))
		do
			currPath="$currPath/pc1/sublab"
			mkdir -p $currPath
			echo "pc1[0]=A" >> $currPath/lab.conf
			echo "pc1[image]=kathara/dind" >> $currPath/lab.conf
			
			curName="${curName}pc1."
		done

		echo "ifconfig 10.0.0.2/24 eth0 up" >> $currPath/pc1.startup

		echo "A.=A.$curName" >> labs/lab_$i/lab.int


		cd labs/lab_$i
		/usr/bin/time -o time_start.txt -p kathara lstart --privileged

		kathara connect --shell "ping -c 100 10.0.0.2" pc1 > ping.txt

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