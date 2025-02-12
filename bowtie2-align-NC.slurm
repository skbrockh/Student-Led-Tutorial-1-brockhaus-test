#!/bin/bash
#SBATCH --job-name=SRR16574675_bowtie2
#SBATCH --partition=RM-shared
#SBATCH --ntasks=16
#SBATCH --mem=31G  # Increased memory for sorting
#SBATCH --time=04:00:00
#SBATCH --output=SRR16574675_bowtie2.log
#SBATCH --mail-user=your-email@svsu.edu
#SBATCH --mail-type=ALL

# Load required software
module load bowtie2/2.4.4

# Define file paths and directories
WORKDIR="/ocean/projects/agr250001p/your-username"
READS_1="$WORKDIR/SRR16574675_1.fastq"
READS_2="$WORKDIR/SRR16574675_2.fastq"
REFERENCE="$WORKDIR/Homo_sapiens.GRCh38.dna.alt.fa"
SAM_OUTPUT="$WORKDIR/aligned.sam"

#echo "Indexing reference genome..."
#bowtie2-build --threads 16 $REFERENCE reference_index

echo "Running Bowtie2..."
bowtie2 --very-fast -p 16 -x reference_index -1 $READS_1 -2 $READS_2 -S $SAM_OUTPUT

echo "Pipeline completed successfully!"
