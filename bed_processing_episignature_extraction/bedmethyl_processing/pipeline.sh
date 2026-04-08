#!/bin/bash

preprocess() {
    local file=$1
    local outputPath=$2
    local outName=$(basename "$file" .bedmethyl.gz)
    echo "Removing extra cols from '$outName'..."

    zcat "$file" |
        awk -F"\t" '$4=="m"' |
        cut -f 1-11 |
        sed 's/^chr//' |
        gzip -9 > "$output_path"/"${outName}".bed.gz
}

if [ -z "$1" ]; then
  echo "Usage: $0 /path/bedmethyl/dir/"
  exit 1
fi

input_path="$1"
output_path=preprocessed_bedmethyl
mkdir -p "$output_path"

# Pre-processin steps:
# - Decompress
# - Filter out '5hmC' marks (otherwise error of 'size index')
# - Keep only 11 first cols
# - Remove 'chr' prefix to contig names
# - Recompr cuz downstream 'bedtools intersect' supports gzipped bed
#
for file in "$input_path"/*.bedmethyl.gz; do
    preprocess "$file" "$outputPath"
done
