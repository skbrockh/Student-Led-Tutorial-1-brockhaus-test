#!/bin/bash
#SBATCH --job-name=SRR16574651_bowtie2
#SBATCH --partition=RM-shared
#SBATCH --ntasks=16
#SBATCH --mem=31G  # Increased memory for sorting
#SBATCH --time=04:00:00
#SBATCH --output=SRR16574651_bowtie2.log
#SBATCH --mail-user=your-email@svsu.edu
#SBATCH --mail-type=ALL

# Load required software
module load bowtie2/2.4.4

# Define file paths and directories
WORKDIR="/ocean/projects/agr250001p/your-username"
READS_1="$WORKDIR/SRR16574651_1.fastq"
READS_2="$WORKDIR/SRR16574651_2.fastq"
REFERENCE="$WORKDIR/Homo_sapiens.GRCh38.dna.alt.fa"
SAM_OUTPUT="$WORKDIR/aligned.sam"

#echo "Indexing reference genome..."
#bowtie2-build --threads 16 $REFERENCE reference_index

echo "Running Bowtie2..."
bowtie2 --very-fast -p 16 -x reference_index -1 $READS_1 -2 $READS_2 -S $SAM_OUTPUT

echo "Converting and Sorting BAM in one step..."
samtools view -@ 8 -bS $SAM_OUTPUT | samtools sort -@ 8 -m 10G -T /scratch/tmp_sort -o $SORTED_BAM

echo "Indexing BAM file..."
samtools index $SORTED_BAM

echo "Calling SNPs with BCFtools..."
bcftools mpileup -Ou -f $REFERENCE $SORTED_BAM | bcftools call -mv -Ob -o $BCF_OUTPUT

echo "Converting BCF to VCF..."
bcftools view -Ov -o $VCF_OUTPUT $BCF_OUTPUT

echo "Compressing and indexing VCF..."
bgzip -c $VCF_OUTPUT > $COMPRESSED_VCF
bcftools index $COMPRESSED_VCF

echo "Pipeline completed successfully!"
