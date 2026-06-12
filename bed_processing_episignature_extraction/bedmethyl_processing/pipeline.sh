#!/bin/bash

set -euo pipefail  # Bash best practice

preprocess() {
    # Pre-processin steps:
    # - Decompress
    # - Filter out '5hmC' marks (otherwise error of 'size index')
    # - Filter on 'N_valid_cov' threshold
    # - Keep only 11 first cols
    # - Remove 'chr' prefix to contig names
    # - Recompr cuz downstream 'bedtools intersect' supports gzipped bed
    #
    local file=$1
    local output_path=$2
    local THRESHOLD=$3
    local outName=$(basename "$file" .bedmethyl.gz)
    echo "Removing extra cols from '$outName'..."

    zcat "$file" |
        awk -v thresh=$THRESHOLD -F"\t" '$4=="m" && $10>=thresh' |
        cut -f 1-11 |
        sed 's/^chr//' |
        gzip -9 > "$output_path"/"${outName}".bed.gz
}
export -f preprocess

if [ -z "$1" ]; then
  echo "Usage: $0 /path/bedmethyl/dir/"
  exit 1
fi

threshold=0
if [ ! -z "$2" ]; then
    threshold=$2
fi

input_path="$1"
output_path=preprocessed_bedmethyl
mkdir -p "$output_path"

for file in "$input_path"/*.bedmethyl.gz; do
    echo preprocess "$file" "$output_path" "$threshold"
done > preprocess_cmds.sh

# Run in parallel:
NB_JOBS=8
parallel --jobs $NB_JOBS --keep-order < preprocess_cmds.sh
rm preprocess_cmds.sh
