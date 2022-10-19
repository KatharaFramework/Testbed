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
				echo "(time -p /venv/bin/python3.9 /kathara/src/kathara.py lstart -d sublab/ --privileged) > /shared/time_startup_pc$j.txt 2>&1" > $currPath/pc$j.startup
				n_of_files=$(expr $depth - $j - 1)
				echo "while [ \$(ls -A /sublab/shared | wc -l) -ne $n_of_files ]; do continue; done" >> $currPath/pc$j.startup
				echo "count=\$(cat /sublab/shared/* | grep real | wc -l); while [ \$count -ne $n_of_files ]; count=\$(cat /sublab/shared/* | grep real | wc -l); done" >> $currPath/pc$j.startup
				echo "mv /sublab/shared/* /shared" >> $currPath/pc$j.startup
			fi

			currPath="$currPath/pc$j/sublab"
		done

		if [ $i -eq $depth ]; then
			cd labs/lab_$i
			/usr/bin/time -o time_startup.txt -p /home/tommaso/Code/Kathara-Framework/Kathara/venv/bin/python3 /home/tommaso/Code/Kathara-Framework/Kathara/src/kathara.py lstart --privileged
		
			# /usr/bin/time -o time_shutdown.txt -p /home/tommaso/Code/Kathara-Framework/Kathara/venv/bin/python3 /home/tommaso/Code/Kathara-Framework/Kathara/src/kathara.py lclean
			
			cd ../..
			echo ""
		fi
		

		
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