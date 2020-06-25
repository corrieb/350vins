#!/bin/bash

MODEL=$1
VINRANGEFROM=$2
VINRANGETO=$3
VINPREFIX=$4
VINPOSTFIX=$5

getcarmodel () {
   echo "$1" | grep "card-title" | cut -d ' ' -f 5 | sed 's/<\/h4>//g'
}

getstatus () {
   echo "$1" | grep "Car Status:" | cut -d '>' -f 3 | sed 's/<\/b//g'
}

getimgurl () {
   echo "$1" | grep "https://build.ford.com/dig/Ford/Mustang/2020/HD-THUMB/Image"
}

getcolorcode() {
   imgurl=$(getimgurl "$1")
   echo "$imgurl" | grep -o 'P8J.*' | cut -d '.' -f 3
}

getstripecode() {
   imgurl=$(getimgurl "$1")
   echo "$imgurl" | grep -o 'PRE.*' | cut -d '.' -f 2
}

getoptions() {
   imgurl=$(getimgurl "$1")
   echo "$imgurl" | grep -o 'SLB.*' | cut -d ']' -f 1
}

getdealer() {
   echo "$1" | grep -A 1 "Dealer</th>" | tr -d '\n' | cut -d '>' -f 4 | sed 's/<\/th//g'
}

getaddress() {
   echo "$1" | grep -A 1 "Address</th>" | tr -d '\n' | cut -d '>' -f 4 | sed 's/<\/a//g'
}

getreceipt() {
   echo "$1" | grep -A 1 "Receipt Date" | tr -d '\n' | cut -d '>' -f 4 | sed 's/<\/td//g'
}

getproduction() {
   echo "$1" | grep -A 1 "Production Date" | tr -d '\n' | cut -d '>' -f 4 | sed 's/<\/td//g'
}

if [ "$#" -ne 5 ]; then
    echo "Usage: ./pull-data.sh <model> <from 4-digit VIN> <to 4-digit VIN> <VIN prefix> <VIN postfix>"
    exit 1
fi

for i in $(seq -f "%04g" $VINRANGEFROM $VINRANGETO); 
do
   vin=$(./compute-vin.sh "$i" "$VINPREFIX" "$VINPOSTFIX")
   output=$(curl -s https://trackmymustang.com/checkvin?vin=$vin)
   echo $output | grep "$MODEL" > /dev/null 2>&1; 
   if [ $? -eq 0 ]; then
      model=$(getcarmodel "$output")
      status=$(getstatus "$output")
      color=$(getcolorcode "$output")
      stripe=$(getstripecode "$output")
      options=$(getoptions "$output")
      dealer=$(getdealer "$output")
      address=$(getaddress "$output")
      receipt=$(getreceipt "$output")
      production=$(getproduction "$output")
      echo "$vin;$model;$status;$color;$stripe;$dealer;$address;$receipt;$production;$options"
   fi
done
