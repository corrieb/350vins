#!/bin/bash
vinrangefrom=14
vinrangeto=26
output="combined.csv"

if [ -f $output ]; then
    rm $output
fi

for i in $(seq $vinrangefrom $vinrangeto); 
do
    let start=$i*100
    let rend=$start+100
    cat data/$start-$rend-all.csv >> $output
done

lines=$(wc -l < combined.csv | xargs)
echo "Combined file $output has $lines lines"
