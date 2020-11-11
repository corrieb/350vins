#!/bin/bash

vins=(
1FA6P8JZ6L5552455
1FA6P8JZ1L5552458
1FA6P8JZ7L5552464
)

for vin in "${vins[@]}";
do
    wget -O ~/Downloads/$vin.pdf "http://www.windowsticker.forddirect.com/windowsticker.pdf?vin=$vin"
done
