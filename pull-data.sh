#!/bin/bash

vinrangefrom=1750
vinrangeto=1800

computevin () {
   vin=$1
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
   echo "1FA6P8JZ"$checkdigit"L555"$1
}

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

for i in $(seq -f "%04g" $vinrangefrom $vinrangeto); 
do
   vin=`computevin "$i"`
   output=`curl -s https://trackmymustang.com/checkvin?vin=$vin`
   echo $output | grep "GT350" > /dev/null 2>&1; 
   if [ $? -eq 0 ]; then
      model=`getcarmodel "$output"`
      status=`getstatus "$output"`
      color=`getcolorcode "$output"`
      stripe=`getstripecode "$output"`
      options=`getoptions "$output"`
      dealer=`getdealer "$output"`
      address=`getaddress "$output"`
      receipt=`getreceipt "$output"`
      production=`getproduction "$output"`
      echo "$vin;$model;$status;$color;$stripe;$dealer;$address;$receipt;$production;$options"
   fi
done
