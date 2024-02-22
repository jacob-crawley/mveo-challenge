#!/bin/bash

# A script to move training data from the original dataset to a new directory
# split up into train/val/test (70/15/15), change the folder names accordingly.

# This runs from the root of my /fastdata/ btw, you change it to be from your /mveo-challenge 

# Move into the original dataset directory
cd mveo-dataset/labeled_train/Nice/BDORTHO

# Shuffle the files
shuf -n 1200 -e * > /fastdata/acc19jc/shuffled_files.txt

cd /fastdata/acc19jc/
# Calculate the number of files for each partition
total_files=$(wc -l < shuffled_files.txt)
train_count=$(( $total_files * 70 / 100 ))
validation_count=$(( $total_files * 15 / 100 ))

echo "Total = ${total_files}"
echo "Train = ${train_count}"
echo "Val = ${validation_count}"
echo "Test = $((total_files - train_count - validation_count))"


rg_list="shuffled_files_rg.txt"
ua_list="shuffled_files_ua.txt"

# Copy filenames from shuffled_files and add correct names for the other folders 
while IFS= read -r line; do 
    file_no_extension="${line%.*}"
    rg_file="${file_no_extension}_RGEALTI.tif"
    ua_file="${file_no_extension}_UA2012.tif"

    echo "$rg_file" >> "$rg_list"
    echo "$ua_file" >> "$ua_list"
done < "shuffled_files.txt"

cd /fastdata/acc19jc/mveo-dataset/labeled_train/Nice/BDORTHO
# Split the files
head -n $train_count /fastdata/acc19jc/shuffled_files.txt | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/train/Nice/BDORTHO
tail -n +$(( $train_count + 1 )) /fastdata/acc19jc/shuffled_files.txt | head -n $validation_count | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/train_val/Nice/BDORTHO
tail -n +$(( $train_count + $validation_count + 1 )) /fastdata/acc19jc/shuffled_files.txt | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/test/Nice/BDORTHO

cd /fastdata/acc19jc/mveo-dataset/labeled_train/Nice/RGEALTI
head -n $train_count /fastdata/acc19jc/shuffled_files_rg.txt | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/train/Nice/RGEALTI
tail -n +$(( $train_count + 1 )) /fastdata/acc19jc/shuffled_files_rg.txt | head -n $validation_count | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/train_val/Nice/RGEALTI
tail -n +$(( $train_count + $validation_count + 1 )) /fastdata/acc19jc/shuffled_files_rg.txt | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/test/Nice/RGEALTI

cd /fastdata/acc19jc/mveo-dataset/labeled_train/Nice/UrbanAtlas
head -n $train_count /fastdata/acc19jc/shuffled_files_ua.txt | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/train/Nice/UrbanAtlas
tail -n +$(( $train_count + 1 )) /fastdata/acc19jc/shuffled_files_ua.txt | head -n $validation_count | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/train_val/Nice/UrbanAtlas
tail -n +$(( $train_count + $validation_count + 1 )) /fastdata/acc19jc/shuffled_files_ua.txt | xargs -I {} cp {} /fastdata/acc19jc/new-dataset/test/Nice/UrbanAtlas

# Move back to the parent directory
cd /fastdata/acc19jc/
