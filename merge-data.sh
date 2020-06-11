#!/bin/bash
oldfile=$1
newfile=$2

combined=()

loadData () {
    IFS=$'\n' read -d '' -r -a lines < $1
    for line in "${lines[@]}";
    do
        # prepend a sort key to each line
        vin=`echo "$line" | cut -d ';' -f 1`
        sortkey=`echo "$vin" | tail -c4`
        newline=`echo "$sortkey"\;"$line"`
        # add the line with the sort key to the combined array
        combined+=("$newline")
    done
}

# load the old data and then the new data into the combined array
# the order matters because the loop below will always prefer the new data if it exists
loadData $oldfile
loadData $newfile

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
        echo $line | cut -d ';' -f 2-
    fi
done
