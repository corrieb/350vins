#!/bin/bash

PREFIX=$1
POSTFIX=$2
RANGEFROM=$3
RANGETO=$4

if [ "$#" -ne 4 ]; then
    echo "Usage: ./compute-vin-range.sh <VIN prefix> <VIN postfix> <from 4-digit VIN> <to 4-digit VIN>"
    exit 1
fi

for i in $(seq -f "%04g" $RANGEFROM $RANGETO); 
do
   ./compute-vin.sh "$i" "$PREFIX" "$POSTFIX"
done
