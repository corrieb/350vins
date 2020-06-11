#!/bin/bash

vinrangefrom=5
vinrangeto=17

olddir="old_data"
datadir="data"
targetdir="merged_data"

mkdir $targetdir
for i in $(seq $vinrangefrom $vinrangeto); 
do
    let start=$i*100
    let rend=$start+100
    filename="$start-$rend-all.csv"
    ./merge-data.sh "$olddir/$filename" "$datadir/$filename" > "$targetdir/$filename"
done
