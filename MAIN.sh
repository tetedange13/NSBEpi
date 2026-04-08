#!/usr/bin/env bash


set -euo pipefail  # Bast best pratice
#set -x  # DEBUG


# 0) Put/symlink all bedmethyl.gz into same dir:
#    Use 'combined' one (NSBEpi precise: NON STRAND SPECIFIC)


# 1) Use a modified version of './remove_extra_col.sh' to pre-process '.bedmethyl.gz'
bash bed_processing_episignature_extraction/bedmethyl_processing/pipeline.sh input_bedmethyl/


# 2) Extract episign for each bedmethyl (against all 'hg38_episignature_cordinates/*')
bash bed_processing_episignature_extraction/episignature_extraction/extract_episignatures.sh


# 3) Convert notebook to python script and run 'script.py'
set +u
source /home/felix/.local/share/mamba/etc/profile.d/mamba.sh && mamba activate /home/felix/.local/share/mamba/envs/NSBEpi
set -u

jupyter nbconvert --to script SVM_read_from_bed.ipynb && \
        python SVM_read_from_bed.py /data/work/CHUUMI/felix/data/methyl/NSBEpi/extracted_episign && \
rm SVM_read_from_bed.py


exit
# 3-bis) Run notebook to classify
jupyter execute --output toto SVM_read_from_bed.ipynb

# 3-ter) User papermill package
papermill \
	SVM_read_from_bed.ipynb toto.json \
	-p input_folder_path '/data/work/CHUUMI/felix/data/methyl/NSBEpi/extracted_episign' \
	--stdout-file toto.txt && \
rm toto.json
# -> But only 'toto.txt' is interesting, 'toto.json' is all NB outputs
