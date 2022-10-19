#!/bin/bash

set -e

usage()
{
	echo "usage: test.sh [[-d depth] | [-h]]"
}

test()
{
	rm -Rf labs/

	for (( i=1; i<=$depth; i++ ))
	do
		echo "Generating lab with depth=$i..."

		mkdir -p labs/lab_$i

		currPath="labs/lab_$i"

		for (( j=1; j<=$i; j++ ))
		do		
			mkdir -p $currPath
		
			echo "pc$j[0]=\"A\"" >> $currPath/lab.conf
			if [ $j -ne $i ]; then
				echo "pc$j[nested]=\"true\"" >> $currPath/lab.conf
				echo "kathara lstart -d sublab/ --privileged" > $currPath/pc$j.startup
			fi

			currPath="$currPath/pc$j/sublab"
		done

		cd labs/lab_$i

		start_ts=$(date +%s)
		kathara lstart
		result=$(kathara linfo | grep Running | wc -l)
		while [ "$result" -eq "0" ]
		do
			sleep 0.5
			result=$(kathara linfo | grep Running | wc -l)
		done
		end_ts=$(date +%s)

		expr $end_ts - $start_ts > time_start.txt

		start_ts=$(date +%s)
		kathara lclean
		kathara linfo
		while [ "$?" -eq "0" ]
		do
			sleep 0.5
			kathara linfo
		done
		end_ts=$(date +%s)

		expr $end_ts - $start_ts > time_clean.txt

		cd ../..
		echo ""
	done

	echo "Done."
}

depth=""

while [ "$1" != "" ]; do
	case $1 in
		-d | --depth )        shift
								depth=$1
								;;
		-h | --help )           usage
								exit
								;;
		* )                     usage
								exit 1
	esac
	shift
done

if [ "$depth" != "" ]
then
	test
else
	usage
fi