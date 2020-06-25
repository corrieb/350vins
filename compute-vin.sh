#!/bin/bash

INPUT=$1
PREFIX=$2
POSTFIX=$3

if [ "$#" -ne 3 ]; then
    echo "Usage: ./compute-vin.sh <4-digit VIN> <VIN prefix> <VIN postfix>"
    exit 1
fi

vin=$INPUT
let first=8+42+6+30+28+24+2+90
let middle=27+40+35+30
let one=${vin:0:1}*5
let two=${vin:1:1}*4
let three=${vin:2:1}*3
let four=${vin:3:1}*2
let sum=first+middle+one+two+three+four
let mod=sum%11
checkdigit=""
if [ $mod == 10 ]; then 
    checkdigit="X"
else
    checkdigit=`echo $mod`
fi
echo "$PREFIX$checkdigit$POSTFIX$1"
