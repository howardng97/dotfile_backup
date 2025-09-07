#!/bin/bash

hour=$(date +%H)

if [ "$hour" -ge 17 ] || [ "$hour" -le 8 ]; then
    hyprsunset -t 5000
else
    hyprsunset -t 6000
fi
