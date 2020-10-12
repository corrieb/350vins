#!/bin/bash

vins=(
1FA6P8JZ9L5552076
1FA6P8JZ4L5552129
1FA6P8JZ2L5552291
)

for vin in "${vins[@]}";
do
    wget -O ~/Downloads/$vin.pdf "http://www.windowsticker.forddirect.com/windowsticker.pdf?vin=$vin"
done
