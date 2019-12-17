#!/bin/bash

set -e
set -x

$NETKIT_HOME/kstart

folder_hash=$($NETKIT_HOME/kinfo -n)

result=$(kubectl -n $folder_hash get pods 2>/dev/null | grep "0/1" | wc -l)

while [ "$result" -gt "0" ]
do
    sleep 1

    result=$(kubectl -n $folder_hash get pods 2>/dev/null | grep "0/1" | wc -l)
done