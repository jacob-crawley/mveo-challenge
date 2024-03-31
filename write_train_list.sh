#!/bin/bash

# Takes the list of files for training and creates a new coordinate list
# Run this using: "./write_train_list.sh <input_file>"

# Define the list of coordinates
coordinates=(0 200 400 600 800 1000 1200 1400 1600 1745)

# Check if input file is provided as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1

# Check if the provided argument is a file
if [ ! -f "$input_file" ]; then
    echo "Error: $input_file is not a file"
    exit 1
fi

# Create a new file to write the output
output_file="new_train_coord_list.txt"
> "$output_file"  # Clear the output file if it exists

# Iterate through each line in the input file
while IFS= read -r line; do
    # Iterate through the coordinates and write each line with coordinates to the output file
    for x_coord in "${coordinates[@]}"; do
        for y_coord in "${coordinates[@]}"; do
            echo "$line $x_coord $y_coord 1.0" >> "$output_file"
        done
    done
done < "$input_file"

echo "Output with coordinates has been written to $output_file"
