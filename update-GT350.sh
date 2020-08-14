#!/bin/bash
vinrangefrom=8
vinrangeto=22

pullIfNotExists() {
    if [ ! -f $3 ]; then
        ./pull-data-GT350.sh $1 $2 > "$3.tmp"
        mv "$3.tmp" $3
    fi
}

if [ ! -d old_data ]; then
    mv data old_data
    mkdir data
else
    echo "Old data exists. Stale data or incomplete run."
    exit 1
fi

for i in $(seq $vinrangefrom $vinrangeto); 
do
    let start=$i*100
    let end=$start+99
    let rend=$end+1
    pullIfNotExists $start $end data/$start-$rend-all.csv
done

wait 
