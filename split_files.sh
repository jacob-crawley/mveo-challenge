#!/bin/bash
# Split the list of files in labeled_train (train_files.txt) randomly into 2 sets by %
# To use run: "./split_files.sh <path_to_list_of_files> <percentage>"
# Check if input file is provided as argument
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file> <percentage>"
    exit 1
fi

input_file=$1
percentage=$2

# Check if the provided argument is a file
if [ ! -f "$input_file" ]; then
    echo "Error: $input_file is not a file"
    exit 1
fi

# Check if percentage is between 0 and 100
if [ $percentage -lt 0 ] || [ $percentage -gt 100 ]; then
    echo "Error: Percentage must be between 0 and 100"
    exit 1
fi

# Shuffle the lines in the input file
shuffled_file="shuffled_$input_file"
shuf "$input_file" > "$shuffled_file"

# Calculate the number of lines for the split
total_lines=$(wc -l < "$shuffled_file")
split_lines=$((($total_lines * $percentage) / 100))

# Make sure the smaller split is a multiple of 16
split_lines=$((split_lines / 16 * 16))
remaining_lines=$((total_lines - split_lines))

# Split the shuffled lines into two files
split_file1="split1_$input_file"
split_file2="split2_$input_file"

head -n "$split_lines" "$shuffled_file" > "$split_file1"
tail -n "$remaining_lines" "$shuffled_file" > "$split_file2"

echo "Lines shuffled and split into $percentage%:"
echo "Split 1 ($split_file1): $(wc -l < "$split_file1") lines"
echo "Split 2 ($split_file2): $(wc -l < "$split_file2") lines"

# Clean up shuffled file
rm "$shuffled_file"
