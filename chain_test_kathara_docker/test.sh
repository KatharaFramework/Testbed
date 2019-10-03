#!/bin/bash

usage()
{
    echo "usage: test.sh [[-r n_routers] | [-h]]"
}

test()
{
    for (( i=1; i<=$n_routers; i++ ))
    do
       echo ""
       echo "Testing lab with $i routers..."

       python generator.py -r $i -d labs/lab_$i
       cd labs/lab_$i
       /usr/bin/time -o time_start.txt -p $NETKIT_HOME/lstart

       sudo docker exec netkit_1000_server ping -c 5 10.0.0.2 > ping.txt

       /usr/bin/time -o time_clean.txt -p $NETKIT_HOME/lclean

       cd ../..
    done

    echo ""
    echo "Saving test results on CSV files..."
    cd labs/
    python test_results.py
    mv start_time_results.csv ../start_time_results.csv
    mv clean_time_results.csv ../clean_time_results.csv
    mv ping_results.csv ../ping_results.csv

    echo ""
    echo "Done."
}


n_routers=""

while [ "$1" != "" ]; do
    case $1 in
        -r | --routers )        shift
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