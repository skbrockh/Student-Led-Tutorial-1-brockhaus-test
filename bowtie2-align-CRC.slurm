#!/bin/bash
#SBATCH --job-name=aligned_bowtie2
#SBATCH --partition=RM-shared
#SBATCH --ntasks=16
#SBATCH --mem=31G  # Increased memory for sorting
#SBATCH --time=04:00:00
#SBATCH --output=aligned_bowtie2.log
#SBATCH --mail-user=your-email@svsu.edu
#SBATCH --mail-type=ALL

# Load required software
module load bowtie2/2.4.4
module load samtools
module load bcftools

# Define file paths and directories
WORKDIR="/ocean/projects/agr250001p/your-username"
READS_1="$WORKDIR/SRR16574675_1.fastq"
READS_2="$WORKDIR/SRR16574675_2.fastq"
REFERENCE="$WORKDIR/Homo_sapiens.GRCh38.dna.alt.fa"
SAM_OUTPUT="$WORKDIR/SRR1657467.sam"
SORTED_BAM="$WORKDIR/SRR1657467_sorted.bam"
BCF_OUTPUT="$WORKDIR/SRR1657467.bcf"
VCF_OUTPUT="$WORKDIR/SRR1657467.vcf"
COMPRESSED_VCF="$WORKDIR/SRR1657467.vcf.gz"

#echo "Indexing reference genome..."
#bowtie2-build $REFERENCE human_genome_reference

echo "Running Bowtie2..."
bowtie2 --very-fast -p 16 -x $REFERENCE -1 $READS_1 -2 $READS_2 -S $SAM_OUTPUT

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
