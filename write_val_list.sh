#!/bin/bash

# Takes the list of files for training and creates a new val_image_list
# Run this using: "./write_val_list.sh <input_file>"

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
output_file="new_val_list.txt"
> "$output_file"  # Clear the output file if it exists

# Iterate through each line in the input file
while IFS= read -r line; do
    echo "$line -1 -1 1.0" >> "$output_file"
done < "$input_file"

echo "Output with coordinates has been written to $output_file"
