#!/bin/bash
charKeys=(A B C D E F G H J K L M N P R S T U V W X Y Z "1" "2" "3" "4" "5" "6" "7" "8" "9")
charVals=(1 2 3 4 5 6 7 8 1 2 3 4 5 7 9 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9)

weights=(8 7 6 5 4 3 2 10 0 9 8 7 6 5 4 3 2)

INPUT=$1
PREFIX=$2
POSTFIX=$3

if [ "$#" -ne 3 ]; then
    echo "Usage: ./compute-vin.sh <4-digit VIN> <VIN prefix> <VIN postfix>"
    exit 1
fi

# Takes a character and returns the value assigned to it - see arrays above
charValForKey() {
    for i in "${!charKeys[@]}";
    do
        if [ ${charKeys[i]} == $1 ]; then
            echo ${charVals[i]}
            return 0
        fi
    done
    return -1
}

# Takes a string, finds the value for each character, multiples it by the index weight and sums the total
computeStringVal() {
    length=${#1}
    total=0
    for i in $(seq 1 $length);
    do 
        charKey=${1:i-1:1}
        charVal=$(charValForKey "$charKey")
        weight=${weights[i-1]}
        let result=charVal*weight
        let total+=result
    done
    echo $total
}

# Note that in order for the weights to be correctly calculated, 
# the check digit needs to be substituted for a meaningless character
sum=$(computeStringVal "$PREFIX"_"$POSTFIX$INPUT")
let mod=sum%11
checkdigit=""
if [ $mod == 10 ]; then 
    checkdigit="X"
else
    checkdigit=`echo $mod`
fi
echo "$PREFIX$checkdigit$POSTFIX$1"
