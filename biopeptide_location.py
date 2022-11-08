import argparse
import pandas
from Bio import SeqIO
from regex import finditer

parser = argparse.ArgumentParser()
parser.add_argument("infile", help='Input file with bioactive peptide list', type=argparse.FileType('r'))
parser.add_argument("fasta", help='Input fasta file to check', type=argparse.FileType('r'))
parser.add_argument("output", help='Output file', type=argparse.FileType('w', encoding='UTF-8'))

args = parser.parse_args()
outputFile = args.output

# variables going to need later
# read in the peptide list as a pandas dataframe
peptides = pandas.read_csv(args.infile, sep='\t')

# read in the fasta sequences using biopython
gene_sequences = SeqIO.parse(args.fasta, "fasta")
headerLine = "gene_id\tpeptide_ID\tpeptide_Name\tNumber\tSequence\tLocation"
print(headerLine, file=outputFile)

for gene in gene_sequences:
    geneID = gene.id
    geneSequence = str(gene.seq)

    for row in peptides.itertuples():
        peptideID = row.ID
        peptideSequence = row.Sequence.strip().replace('~', '') # strip whitespace and "~"
        peptideName = row.Name.strip()
        peptideCounter = 0

        # Base line text to write in case of match
        line = geneID + "\t" + str(peptideID) + "\t" + str(peptideName) + "\t" + "peptideCounter" + "\t" \
            + str(peptideSequence) + "\t"

        # Add the locations to the end of the line to print
        for match in finditer(str(peptideSequence), str(geneSequence), overlapped=0):
            if peptideCounter == 0:
                line = line + "[" + str(match.start() + 1) + "-" + str(match.end()) + "]"
            else:
                line = line + ",[" + str(match.start() + 1) + "-" + str(match.end()) + "]"
            peptideCounter += 1

        # Update the peptide counter with the actual count
        line = line.replace("peptideCounter", str(peptideCounter))

        # Only print lines that actually had matches
        if peptideCounter != 0:
            print(line, file=outputFile)
outputFile.close()
