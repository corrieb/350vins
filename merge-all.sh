#!/bin/bash

vinrangefrom=0
vinrangeto=27

olddir="old_data"
datadir="data"
targetdir="merged_data"

if [ ! -d $olddir ]; then
    echo "./$olddir does not exist. Nothing to merge."
    exit 1
fi

if [ ! -d $datadir ]; then
    echo "./$datadir does not exist. Nothing to merge."
    exit 1
fi

if [ -d $targetdir ]; then
    echo "Merged data already exists"
    exit 0
fi

mkdir $targetdir
for i in $(seq $vinrangefrom $vinrangeto); 
do
    let start=$i*100
    let rend=$start+100
    filename="$start-$rend-all.csv"
    oldFile="$olddir/$filename"
    newFile="$datadir/$filename"
    if [ -f $newFile ] || [ -f $oldFile ]; then
        ./merge-data.sh "$olddir/$filename" "$datadir/$filename" > "$targetdir/$filename"
    else
        echo "No files to process: $oldFile -> $newFiles"
    fi
done
