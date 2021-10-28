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

# Repo for pdist outputs
mkdir $BASE_DIR/outputs/9_pdist/



# ********* Jobs creation *************************
# -------------------------------------------------

# ------------------------------------------------------------------------------
# Job 0 

jobfile0=0_filter.tmp # temp file
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


zcat < $BASE_DIR/outputs/6_genotyping/6_2_all/filterd.allBP.vcf.gz | \
       sed -e 's/|/\//g' -e 's/1\/0/\.\/\./g' -e 's/0\/1/\.\/\./g' | \
       gzip > $BASE_DIR/outputs/9_pdist/filterd.allBP_nhp.vcf.gz


# Convert to fasta format (Perl script available at https://github.com/JinfengChen/vcf-tab-to-fasta)
#wget https://raw.githubusercontent.com/JinfengChen/vcf-tab-to-fasta/master/vcf_tab_to_fasta_alignment.pl


vcf-to-tab < $BASE_DIR/outputs/9_pdist/filterd.allBP_nhp.vcf.gz | sed -e 's/\.\/\./N\/N/g' -e 's/\.\//N\/N/g' > $BASE_DIR/outputs/9_pdist/filterd.allBP_nhp.tab

perl $BASE_DIR/vcf_tab_to_fasta_alignment.pl -i $BASE_DIR/outputs/9_pdist/filterd.allBP_nhp.tab > $BASE_DIR/outputs/9_pdist/filterd.allBP_nhp.fas


EOA



jid0=$(sbatch ${jobfile0})
