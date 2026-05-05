set -uo pipefail


add_col() {
	awk -v OFS="\t" '{print $0,"NAME","100.00","+"}' "$1"
}
export -f add_col


bed_to_methMatrix() {
	awk -F"\t" '{print $1":"$2"-"$3"\t"$5}' "$1"
}
export -f bed_to_methMatrix

bedMeth_to_methMatrix() {
	local inBEDm=$1
	local cutOFF=$2
	local sampleName=$(basename $inBEDm .bedmethyl.gz)
	zcat $inBEDm |
        	awk -v thresh=$cutOFF -F"\t" '$4=="m" && $11>=thresh {print $1":"$2"-"$3"\t100.00"}' |
	        sed 's/^chr//' |
        	tsvtk add-header -n coord,$sampleName -o ${sampleName}_methMatrix.tsv.gz
}
export -f bedMeth_to_methMatrix
