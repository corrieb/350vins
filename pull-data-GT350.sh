#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./pull-data-GT350.sh <from 4-digit VIN> <to 4-digit VIN>"
    exit 1
fi

./pull-data.sh "GT350" $1 $2 "1FA6P8JZ" "L555"