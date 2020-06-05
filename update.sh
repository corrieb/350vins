#!/bin/bash

vinrangefrom=5
vinrangeto=17

pullIfNotExists() {
    if [ ! -f $3 ]; then
        ./pull-data.sh $1 $2 > "$3.tmp"
        mv "$3.tmp" $3
    fi
}

if [ ! -d old_data ]; then
    mv data old_data
    mkdir data
fi

pullIfNotExists 500 599 data/500-600-all.csv &
pullIfNotExists 600 699 data/600-700-all.csv &
pullIfNotExists 700 799 data/700-800-all.csv &
pullIfNotExists 800 899 data/800-900-all.csv &
pullIfNotExists 900 999 data/900-1000-all.csv &
pullIfNotExists 1000 1099 data/1000-1100-all.csv &
pullIfNotExists 1000 1099 data/1000-1100-all.csv &
pullIfNotExists 1100 1199 data/1100-1200-all.csv &
pullIfNotExists 1200 1299 data/1200-1300-all.csv &
pullIfNotExists 1300 1399 data/1300-1400-all.csv &
pullIfNotExists 1400 1499 data/1400-1500-all.csv &
pullIfNotExists 1500 1599 data/1500-1600-all.csv &
pullIfNotExists 1600 1699 data/1600-1700-all.csv &
pullIfNotExists 1700 1799 data/1700-1800-all.csv &
wait