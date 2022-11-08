#!/bin/bash
# Usage function, needs to be declared before called
usage() {
        echo "Usage: biopeptide_location.sh -p bioactive_peptide_file -f fasta_file -o output_file_prefix"
        echo "Arguments can be in any order, but all must be set"
}

# Get args
while getopts "f:o:p:h" flag
do
        case "${flag}" in
                f) FASTA=${OPTARG};;
                o) OUTPUT=${OPTARG};;
		p) PEPTIDES=${OPTARG};;
                h) usage;;
                *) usage;;
        esac
done

[ -z "$PEPTIDES" ] && { echo "Bioactive Peptides file not set"; usage; exit 1; }
[ -z "$FASTA" ] && { echo "Reference fasta file not set"; usage;  exit 1; }
[ -z "$OUTPUT" ] && { echo "Output file prefix not set"; usage; exit 1; }


# Make sure the files exist that need to
[ ! -f "$PEPTIDES" ] && { echo "Bioactive Peptides file $INPUT not found"; exit 1; }
[ ! -f "$FASTA" ] && { echo "Reference fasta file $FASTA not found"; exit 1; }

# Get the current directory of this scriprt so we know where the python script is
script_name=$0
script_path=$(dirname "$0")

python3 ${script_path}/biopeptide_location.py $PEPTIDES $FASTA ${OUTPUT}.txt

tail -n +2 ${OUTPUT}.txt | awk -F "\t" '{print $1}' | sort | uniq > ${OUTPUT}_gene_list.txt
tail -n +2 ${OUTPUT}.txt | awk -F "\t" '{print $2}' | sort | uniq > ${OUTPUT}_peptideID_list.txt
tail -n +2 ${OUTPUT}.txt | awk -F "\t" '{print $3}' | sort | uniq > ${OUTPUT}_peptideName_list.txt
tail -n +2 ${OUTPUT}.txt | awk -F "\t" '{a[$2] += $4} END{for (i in a) print i, a[i]}' > ${OUTPUT}_peptideID_list_with_total_counts.txt
tail -n +2 ${OUTPUT}.txt | awk -F "\t" '{print $2}' | sort | uniq -c | sed 's/^ *//g' | sed -e 's/ /\t/g' |  awk -F "\t" '{print $2,$1}' > ${OUTPUT}_peptideID_list_with_counts.txt
