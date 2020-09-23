#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./report.sh <from SHA> <to SHA>"
    exit 1
fi

# Input should be two git commit SHAs - compare from/to
fromsha=$1
tosha=$2

# List of known array names so we can iterate over them in order
# Note that the order of this must be the same as the titles array
arrays=(
    "new" 
    "schedweek"
    "schedday"
    "senttoplant"
    "bodyshop"
    "trimline"
    "produced"
    "received"
    "receivedatjunc"
    "released"
    "rereleased"
    "shippedfromplant" 
    "passing"
    "passingarrival"
    "shippedconvoy"
    "shippedrail"
    "arrivedatjunctionpoint"
    "arrivedrail"
    "delivered"
    "delay"
    "cancelled"
    "vehicledamaged"
    "inorderprocessing"
    "inproduction"
    "intransit"
    "unknown"
)

# Array initialization to match the array names above
new=()
schedweek=()
schedday=()
received=()
receivedatjunc=()
senttoplant=()
bodyshop=()
trimline=()
produced=()
released=()
rereleased=()
passingarrival=()
passing=()
shippedfromplant=()
shippedconvoy=()
shippedrail=()
arrivedatjunctionpoint=()
arrivedrail=()
delivered=()
delay=()
cancelled=()
vehicledamaged=()
inorderprocessing=()
inproduction=()
intransit=()
unknown=()

# List of known status titles so we can iterate over them in order
# Note that the order of this must be the same as the arrays array
titles=(
    "New VINs" 
    "Scheduled to Week"
    "Scheduled to Day"
    "Sent to Plant"
    "Body Shop"
    "Trim Line"
    "Produced"
    "Received"
    "Received at Junction Point"
    "Released"
    "Re-Released"
    "Shipped from Plant" 
    "Passing"
    "Passing Arrival"
    "Shipped CONVOY"
    "Shipped RAIL"
    "Arrived at Junction Point"
    "Arrived RAIL"
    "Delivered"
    "Delay"
    "Cancelled"
    "Vehicle Damaged"
    "In Order Processing"
    "In Production"
    "In Transit"
    "Unknown"
)

combined=()

# Loads all VIN lines from the git diff into an array
loadData () {
    IFS=$'\n' read -d '' -r -a lines < $1
    for line in "${lines[@]}";
    do
        # filter on lines that start +/- and have a 1 (first VIN char)
        firstchars=${line:0:2}
        if [ "$firstchars" == "+1" ] || [ "$firstchars" == "-1" ]; then
            vin=$(echo "$line" | cut -d ';' -f 1)
            sortkey=$(echo "$vin" | tail -c5)   # last 4 digits of the VIN
            # append the +/- to the sortkey to ensure consistent ordering of each VIN pair
            sortkey=$sortkey${line:0:1}
            # remove the +/- from the line itself now that it's part of the sort key
            newline=$(echo "$sortkey;${line:1}")
            combined+=("$newline")
        fi
    done
}

# Sorts each line into VIN order with +/- first/second
# Buckets each VIN into one of a series of arrays depending on Status
sortData () {
    IFS=$'\n' sorted=($(sort <<<"${combined[*]}"))

    prevkey=""
    for i in "${!sorted[@]}";
    do
        line=${sorted[i]}
        nextline=${sorted[i+1]}
        # For a VIN pair, the key should contain the + and the nextkey will contain the -
        key=$(echo "$line" | cut -d ';' -f 1)
        key=${key::${#key}-1} # remove the trailing +/+
        status=$(echo "$line" | cut -d ';' -f 4)
        nextkey=""
        oldstatus=""
        if [ "$nextline" != "" ]; then
            nextkey=$(echo "$nextline" | cut -d ';' -f 1)
            nextkey=${nextkey::${#nextkey}-1} # remove the trailing +/-
            oldstatus=$(echo "$nextline" | cut -d ';' -f 4)
        fi
        # If we have a VIN pair and the Status has definitely changed
        if [ "$key" == "$nextkey" ] && [ "$status" != "$oldstatus" ]; then
#            echo "$oldstatus" "=>" "$status"
            case "$status" in
                "Scheduled to Week")
                    schedweek+=("$line")
                    ;;
                "Scheduled to Day")
                    schedday+=("$line")
                    ;;
                "Received")
                    received+=("$line")
                    ;;
                "Received at Junction Point")
                    receivedatjunc+=("$line")
                    ;;
                "Sent to Plant")
                    senttoplant+=("$line")
                    ;;
                "Body Shop")
                    bodyshop+=("$line")
                    ;;
                "Trim Line")
                    trimline+=("$line")
                    ;;
                "Produced")
                    produced+=("$line")
                    ;;
                "Released")
                    released+=("$line")
                    ;;
                "Re-Released")
                    rereleased+=("$line")
                    ;;
                "Passing Arrival")
                    passingarrival+=("$line")
                    ;;
                "Passing")
                    passing+=("$line")
                    ;;
                "Shipped from Plant")
                    shippedfromplant+=("$line")
                    ;;
                "Shipped CONVOY")
                    shippedconvoy+=("$line")
                    ;;
                "Shipped RAIL")
                    shippedrail+=("$line")
                    ;;
                "Arrived at Junction Point")
                    arrivedatjunctionpoint+=("$line")
                    ;;
                "Arrived RAIL")
                    arrivedrail+=("$line")
                    ;;
                "Delivered")
                    delivered+=("$line")
                    ;;
                "Delay")
                    delay+=("$line")
                    ;;
                "Cancelled")
                    cancelled+=("$line")
                    ;;
                "Vehicle Damaged - A")
                    vehicledamaged+=("$line")
                    ;;
                "In Order Processing")
                    inorderprocessing+=("$line")
                    ;;
                "In Production")
                    inproduction+=("$line")
                    ;;
                "In Transit")
                    intransit+=("$line")
                    ;;
                *)
                    unknown+=("$line")
                    ;;
            esac
        else
            # If the next key and the prev key are different, this is a new VIN
            if [ "$key" != "$nextkey" ] && [ "$key" != "$prevkey" ]; then
                new+=("$line")
            fi
        fi
        prevkey=$key
    done
}

printData () {
    # Iterate over the arrays printing out each one
    for i in "${!arrays[@]}";
    do
        array=${arrays[i]}[@]
        title=${titles[i]}          # This is why it's important that the title and array arrays match
        echo -e "\n- $title"
        for line in "${!array}";    # array name substitution trick
        do
            vin=$(echo "$line" | cut -d ';' -f 2)
            model=$(echo "$line" | cut -d ';' -f 3)
            status=$(echo "$line" | cut -d ';' -f 4)
            paint=$(echo "$line" | cut -d ';' -f 5)
            type=""
            if [ "$paint" == "N4" ]; then
                type="- HEP"
                if [ "$model" == "GT350R" ]; then
                    type="- HEP R"
                fi
            else
                if [ "$model" == "GT350R" ]; then
                    type="- R"
                fi
            fi
            echo $vin $type # $status
        done
    done
}

git diff $fromsha $tosha data > diff.out
if [ $? -eq 0 ]; then
    loadData diff.out
    sortData
    printData
else
    echo "git diff failed"
fi
rm diff.out
