#!/bin/bash

# Lấy giá trị từ fcitx5-remote
input_source=$(fcitx5-remote)

if [ "$input_source" -eq 1 ]; then
    echo "󰯷󰰒"  
elif [ "$input_source" -eq 2 ]; then
    echo "󰰪󰰒" 
else
    echo ""  
fi

