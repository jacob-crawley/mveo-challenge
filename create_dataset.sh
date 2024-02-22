#!/bin/bash

# Move into the data directory
cd mveo-dataset/labeled_train/Nice/BDORTHO

# Shuffle the files
shuf -n 1200 -e * > shuffled_files.txt

# Calculate the number of files for each partition
total_files=$(wc -l < shuffled_files.txt)
train_count=$(( $total_files * 70 / 100 ))
validation_count=$(( $total_files * 15 / 100 ))

echo "Total = ${total_files}"
echo "Train = ${train_count}"
echo "Val = ${validation_count}"
echo "Test = ${total_files - train_count - validation_count}"

# # Split the files
# head -n $train_count shuffled_files.txt | xargs -I {} mv {} ../training
# tail -n +$(( $train_count + 1 )) shuffled_files.txt | head -n $validation_count | xargs -I {} mv {} ../validation
# tail -n +$(( $train_count + $validation_count + 1 )) shuffled_files.txt | xargs -I {} mv {} ../test

# # Move back to the parent directory
# cd ..
