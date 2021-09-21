#!/bin/bash
# by: Floriane Coulmance: 21/09/2021
# usage:
# phylogeny.sh -i <PATH> -j <JOB_ID>
# ------------------------------------------------------------------------------
# PATH corresponds to the path to the base directory, all outputs and necessary
# folder will be created by the script
# JOB_ID corresponds string ids from where you want  the script to be ran
# ------------------------------------------------------------------------------



# ********** Allow to enter bash options **********
# -------------------------------------------------

while getopts i:j: option
do
case "${option}"
in
i) BASE_DIR=${OPTARG};; # get the base directory path
j) JID_RES=${OPTARG};; # get the jobid from which you want to resume
esac
done



# ********* Create necessary repositories *********
# -------------------------------------------------

# Repo for job logs
mkdir $BASE_DIR/logs/

# Repo for figures
mkdir $BASE_DIR/figures/

# Outputs repo
mkdir $BASE_DIR/outputs/
mkdir $BASE_DIR/outputs/7_phylogeny/
mkdir $BASE_DIR/outputs/7_phylogeny/7_1_whg/
mkdir $BASE_DIR/outputs/7_phylogeny/7_2_coi/

# Annex folder for list of files
mkdir $BASE_DIR/outputs/lof/



# ********* Jobs creation *************************
# -------------------------------------------------

# ------------------------------------------------------------------------------
# Job 0

jobfile0=0_ubam.tmp # temp file
cat > $jobfile0 <<EOA # generate the job file
#!/bin/bash
#SBATCH --job-name=0_filter
#SBATCH --partition=carl.p
#SBATCH --output=$BASE_DIR/logs/0_filter_%A_%a.out
#SBATCH --error=$BASE_DIR/logs/0_filter_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=04:00:00

zcat < $BASE_DIR/outputs/6_genotyping/6_1_snp/snp_filterd.vcf.gz | \
       sed -e s/"1|0"/".|."/g -e s/"0|1"/".|."/g | \
       gzip > $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n.vcf.gz


vcftools \
    --gzvcf $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n.vcf.gz \
    --max-missing 0.33 \
    --mac 4 \
    --thin 5000 \
    --recode \
    --out $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n_0.33_mac4_5kb

# Convert to fasta format (Perl script available at https://github.com/JinfengChen/vcf-tab-to-fasta)
wget https://raw.githubusercontent.com/JinfengChen/vcf-tab-to-fasta/master/vcf_tab_to_fasta_alignment.pl

vcf-to-tab < $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n_0.33_mac4_5kb.vcf > $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n_0.33_mac4_5kb.tab
   
perl ~/apps/vcf-tab-to-fasta/vcf_tab_to_fasta_alignment.pl -i $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n_0.33_mac4_5kb.tab > $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n_0.33_mac4_5kb.fas


EOA



# ------------------------------------------------------------------------------
# Job 1

jobfile1=1_raxml.tmp # temp file
cat > $jobfile1 <<EOA # generate the job file
#!/bin/bash
#SBATCH --job-name=1_raxml
#SBATCH --partition=carl.p
#SBATCH --output=$BASE_DIR/logs/1_raxml_%A_%a.out
#SBATCH --error=$BASE_DIR/logs/1_raxml_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=04:00:00


# Reconstruct phylogeny
   # Note: number of invariant sites for Felsenstein correction was calculated as number of
   # variant sites in alignment (109,660) / genome-wide proportion of variant sites
   # (0.05) * genome-wide proportion of invariant sites (0.95)
   raxml-NG --all \
     --msa $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n_0.33_mac4_5kb.fas \
     --model GTR+G+ASC_FELS{2083540} \
     --tree pars{20},rand{20} \
     --bs-trees 100 \
     --threads 24 \
     --worker 4 \
     --seed 123 \
     --prefix $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n_0.33_mac4_5kb


EOA