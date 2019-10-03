#!/bin/bash

folder_hash=$($NETKIT_HOME/kinfo -n)

$NETKIT_HOME/kclean

result=$(kubectl -n $folder_hash get pods 2>/dev/null | grep "1/1" | wc -l)

while [ "$result" -gt "0" ]
do
    sleep 1

    result=$(kubectl -n $folder_hash get pods 2>/dev/null | grep "1/1" | wc -l)
done