#!/bin/bash
oldfile=$1
newfile=$2

combined=()

loadData () {
    if [ ! -f $1 ]; then
        return
    fi
    IFS=$'\n' read -d '' -r -a lines < $1
    for line in "${lines[@]}";
    do
        # prepend a sort key to each line
        vin=`echo "$line" | cut -d ';' -f 1`
        sortkey=`echo "$vin" | tail -c4`
        # add an extra char to ensure ordering from old to new when sorted
        newline=`echo "$sortkey"\;"$2"\;"$line"`
        # add the line with the sort key to the combined array
        combined+=("$newline")
    done
}

if [ "$#" -ne 2 ]; then
    echo "Usage: ./merge-data.sh <old CSV path> <new CSV path>"
    exit 1
fi

# load the old data and then the new data into the combined array
# the order is determined by the alphabetical precedence of the trailing char
loadData $oldfile a
loadData $newfile b

# sort the combined data so that duplicates are easily identified
IFS=$'\n' sorted=($(sort <<<"${combined[*]}"))

# loop works by peeking at the next line to see whether or not to keep the current line
for i in "${!sorted[@]}";
do
    line=${sorted[i]}
    nextline=${sorted[i+1]}
    key=`echo "$line" | cut -d ';' -f 1`
    nextkey=`echo "$nextline" | cut -d ';' -f 1`
    # if the next key is different, this must be the newer of the current key
    if [ "$key" != "$nextkey" ]; then
        # Special case where a vehicle is in transit, but there's no longer data being shown. Assume Delivered
        inTransit=`echo "$line" | grep "In Transit"`
        if [ "$inTransit" != "" ]; then
            prevKey=""
            if [ i > 0 ]; then
                prevLine=${sorted[i-1]}
                prevKey=`echo "$prevLine" | cut -d ';' -f 1`
            fi
            if [ i == 0 ] || [ "$key" != "$prevKey" ]; then
                line=`echo "$line" | sed 's/In Transit/Delivered/g'`
            fi
        fi
        # remove the sort key from the output
        echo $line | cut -d ';' -f 3-
    else
        # Special case to preserve orders that were showing "Cancelled" and now show "In Order Processing"
        isCancelled=`echo "$line" | grep "Cancelled"`
        if [ "$isCancelled" != "" ]; then
            sorted[i+1]=`echo "$nextline" | sed 's/In Order Processing/Cancelled/g'`
        fi
    fi
done
