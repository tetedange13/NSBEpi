#!/bin/bash

set -euo pipefail
#set -x  # DEBUG

# Checking if bedtools is installed
if ! command -v bedtools &> /dev/null; then
    echo "bedtools is not installed. Please install bedtools to run this script."
    exit 1
fi



# path to bed files containing the episignature loci (hg38_episignature_cordinates)
group1_path=/data/work/CHUUMI/felix/data/methyl/NSBEpi/hg38_episignature_cordinates
# path to nanopore bedmethyl file
group2_path=/data/work/CHUUMI/felix/data/methyl/NSBEpi/preprocessed_bedmethyl

# Creating the output folder if it doesn't exist
output_folder="extracted_episign"
mkdir -p "$output_folder"

for file2 in "$group2_path"/*.bed; do

    file2_basename=$(basename "$file2" .bed)

    for file1 in "$group1_path"/*.bed; do

        file1_basename=$(basename "$file1" .bed)

        output_file="${output_folder}/${file1_basename}_${file2_basename}.bed"

        # Performing the intersection using bedtools
        echo bedtools intersect -sorted -a "$file1" -b "$file2" -loj -wa -wb \> "$output_file"

       	#echo "Intersection created: $output_file"
    done
done > extract_episign_cmds.sh


# Run in parallel:
parallel < extract_episign_cmds.sh
rm extract_episign_cmds.sh


echo "Intersections completed!"

