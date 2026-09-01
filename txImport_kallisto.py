#!/usr/bin/env python3


# WARN: Produced file not currently supported by pyDESeq2
#       -> See: https://github.com/scverse/PyDESeq2/pull/451


import sys
from pytximport import tximport
from pytximport.utils import create_transcript_gene_map_from_annotation


if __name__ == "__main__":
    GTF_TO_USE = sys.argv[1] # Eg: tx2gene_ENSEMBLv116.csv or /data/annotations/human/Homo_sapiens.GRCh38.116.gtf
    str_list_files = sys.argv[2]  # Eg: kallisto/quant/CSG123_S28/abundance.tsv,kallisto/quant/CSG456_S27/abundance.tsv

    transcript_gene_map = GTF_TO_USE
    if GTF_TO_USE.endswith(".gtf"):
        # Convert GTF to "tx2gene map":
        # ALT: download one: transcript_gene_map = create_transcript_gene_map(species="human")
        converted_gtf = create_transcript_gene_map_from_annotation(GTF_TO_USE)
        print(f"Created transcript-to-gene map from '{GTF_TO_USE}'")
        transcript_gene_map = converted_gtf

    results = tximport(
        str_list_files.split(","),
        data_type="kallisto",
        abundance_column="est_counts",
        transcript_gene_map=transcript_gene_map,
        output_path="counts.tsv",
        output_path_overwrite=True,
    )
    print("Wrote by-genes file: 'counts.tsv'")
