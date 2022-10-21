#!/bin/bash

set -e

usage()
{
	echo "usage: test.sh [[-d depth] | [-h]]"
}

test()
{
	rm -Rf labs/
	kathara wipe -f

	for (( i=$step; i<=$depth; i=i+$step ))
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
				last_depth=$(expr $i - 1)
				if [ $j -eq $last_depth ]; then
					echo "/venv/bin/python3.9 /kathara/src/kathara.py lstart -d sublab/ --privileged; echo \$(date +%s) > /shared/time_end_startup.txt" > $currPath/pc$j.startup
				elif [ $j -lt $last_depth ]; then
					echo "/venv/bin/python3.9 /kathara/src/kathara.py lstart -d sublab/ --privileged" > $currPath/pc$j.startup
					echo "while [ \$(ls /sublab/shared | wc -l) -eq 0 ]; do continue; done" >> $currPath/pc$j.startup
					echo "while [ -z /sublab/shared/time_end_startup.txt ]; do continue; done" >> $currPath/pc$j.startup
					echo "mv /sublab/shared/time_end_startup.txt /shared/time_end_startup.txt" >> $currPath/pc$j.startup
				fi
			fi

			currPath="$currPath/pc$j/sublab"
		done

		cd labs/lab_$i

		echo $(date +%s) > time_start_startup.txt
		/home/tommaso/Code/Kathara-Framework/Kathara/venv/bin/python3 /home/tommaso/Code/Kathara-Framework/Kathara/src/kathara.py lstart --privileged
		if [ $i -eq 1 ]; then
			echo $(date +%s) > time_end_startup.txt
		else 
			while [ $(ls shared/ | wc -l) -eq 0 ]; do continue; done
			while [ -z shared/time_end_startup.txt ]; do continue; done
			mv shared/time_end_startup.txt .
		fi

		time_start=$(cat time_start_startup.txt)
		time_end=$(cat time_end_startup.txt)
		real_startup_time=$(expr $time_end - $time_start)

		echo $real_startup_time > time_startup.txt

		/usr/bin/time -o time_shutdown.txt -p /home/tommaso/Code/Kathara-Framework/Kathara/venv/bin/python3 /home/tommaso/Code/Kathara-Framework/Kathara/src/kathara.py lclean
		
		cd ../..
		echo ""	
	done

	mv labs/ labs_${depth}_${step}_$(date -Iminutes)/
	echo "Done."
}

depth=""
step=1

while [ "$1" != "" ]; do
	case $1 in
		-d | --depth )        	shift
								depth=$1
								;;
		-s | --step )        	shift
								step=$1
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