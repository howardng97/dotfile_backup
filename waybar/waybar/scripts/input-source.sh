#!/bin/bash

# Lấy giá trị từ fcitx5-remote
input_source=$(fcitx5-remote)

# Ánh xạ giá trị 1 và 2 thành cờ Việt Nam và cờ Mỹ
if [ "$input_source" -eq 1 ]; then
    echo "🇺🇸 EN"  # Cờ Mỹ cho tiếng Anh
elif [ "$input_source" -eq 2 ]; then
    echo "🇻🇳 VI"  # Cờ Việt Nam cho tiếng Việt
else
    echo "❓"  # Dấu chấm hỏi nếu không nhận diện được
fi

