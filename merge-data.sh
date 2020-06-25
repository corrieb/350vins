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

for i in "${!sorted[@]}";
do
    line=${sorted[i]}
    nextline=${sorted[i+1]}
    key=`echo "$line" | cut -d ';' -f 1`
    nextkey=`echo "$nextline" | cut -d ';' -f 1`
    # if the next key is different, this must be the newer of the current key
    if [ "$key" != "$nextkey" ]; then
        # remove the sort key from the output
        echo $line | cut -d ';' -f 3-
    fi
done
