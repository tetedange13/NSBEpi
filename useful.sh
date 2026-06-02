set -uo pipefail


corrected_to_bedMeth(){
	# Turn coord into BED + add fake columns to make a BEDmethyl (only 11 first cols)
	local sampleName=$(basename "$1" .tsv)
	awk 'NR>1 {print $1"\t"$2}' "$1" |
		sed -e 's/:/\t/' -e 's/-/\t/' -e 's/^/chr/' |
		awk -v OFS="\t" '{print $1,$2,$3,"m","10",".",$2,$3,"255,0,0","10",$4*100}' |
		bedtools sort |
	gzip -9 > ${sampleName}.bedmethyl.gz
}


methVal_to_methMatrix() {
	# Takes a TSV as such 'Chr Pos methVal' and convert it to 'Chr:Pos methVal'
	awk -v OFS="\t" '{print $1":"$2-1"-"$2,$3}' "$1" |
		sed 's/^chr//'
}
export -f methVal_to_methMatrix


bedMeth_to_methMatrix() {
	# Version using 'percent_mod' values
        local inBEDm=$1
        local cutOFF=$2
        local sampleName=$(basename $inBEDm .bedmethyl.gz)
        zcat $inBEDm |
                awk -v thresh=$cutOFF -F"\t" '$4=="m" && $5>=0 && $11>=thresh {print $1":"$2"-"$3"\t"$11/100}' |
                sed 's/^chr//' |
                tsvtk add-header -n coord,$sampleName -o ${sampleName}_methMatrix.tsv.gz
}
export -f bed_to_methMatrix

bedMeth_to_methMatrix() {
	# Version setting '100%' as methyl value
	local inBEDm=$1
	local cutOFF=$2
	local sampleName=$(basename $inBEDm .bedmethyl.gz)
	zcat $inBEDm |
        	awk -v thresh=$cutOFF -F"\t" '$4=="m" && $5>=0 && $11>=thresh {print $1":"$2"-"$3"\t100.00"}' |
	        sed 's/^chr//' |
        	tsvtk add-header -n coord,$sampleName -o ${sampleName}_methMatrix.tsv.gz
}
export -f bedMeth_to_methMatrix


bedMeth_to_methData() {
	# Take bedmethyl -> TSV with coord + all other cols like 'N_valid_cov' (interesting ones)
	local inBEDm=$1
	local sampleName=$(basename "$inBEDm" .bedmethyl.gz)
	local colsList=coord,N_valid_cov,percent_mod,N_mod,N_canon,N_other_mod,N_delete,N_fail,N_diff,No_nocall

	zcat "$inBEDm" |
		awk '$4=="m"' |
		cut --complement -f 4,5,6,7,8,9 |
		sed -e 's/^chr//' -e 's/\t/:/' -e 's/\t/-/' |
		tsvtk add-header \
			-n "$colsList" \
			-o ${sampleName}_methData.tsv.gz
}
export -f bedMeth_to_methData
