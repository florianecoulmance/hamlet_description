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
       sed -e 's/1\/0/\.\/\./g' -e 's/0\/1/\.\/\./g' | \
       gzip > $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n.vcf.gz

vcftools \
    --gzvcf $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_n.vcf.gz \
    --max-missing 0.33 \
    --mac 2 \
    --thin 5000 \
    --recode \
    --out $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac2_5kb_n


# Convert to fasta format (Perl script available at https://github.com/JinfengChen/vcf-tab-to-fasta)
#wget https://raw.githubusercontent.com/JinfengChen/vcf-tab-to-fasta/master/vcf_tab_to_fasta_alignment.pl

#vcf-to-tab < $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac1_5kb.recode.vcf > $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac1_5kb.tab

vcf-to-tab < $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac2_5kb_n.recode.vcf | sed -e 's/\.\/\./N\/N/g' -e 's/\.\//N\/N/g' -e 's/[ACGTN\*]\/\*/N\/N/g' > $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac2_5kb_n.tab
   
perl $BASE_DIR/vcf_tab_to_fasta_alignment.pl -i $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac2_5kb_n.tab > $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac2_5kb_n.fas


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


#wget https://github.com/amkozlov/raxml-ng/releases/download/1.0.1/raxml-ng_v1.0.1_linux_x86_64_MPI.zip

#mkdir build && cd build

#cmake -DUSE_MPI=ON -DCMAKE_C_COMPILER=$HOME/anaconda3/envs/raxml/bin/x86_64-conda_cos6-linux-gnu-gcc -DCMAKE_CXX_COMPILER=$HOME/anaconda3/envs/raxml/bin/x86_64-conda_cos6-linux-gnu-cpp -S=$HOME/software/raxml ..

#conda deactivate

ml hpc-env/8.3 CMake/3.15.3-GCCcore-8.3.0 intel/2019b

# Reconstruct phylogeny
   # Note: number of invariant sites for Felsenstein correction was calculated as number of
   # variant sites in alignment (109,660) / genome-wide proportion of variant sites
   # (0.05) * genome-wide proportion of invariant sites (0.95)
   ~/apps/raxml-ng/bin/raxml-ng --all \
     --msa $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac2_5kb_n.fas \
     --model GTR+G+ASC_FELS{2083540} \
     --tree pars{20},rand{20} \
     --bs-trees 100 \
     --threads 24 \
     --worker 4 \
     --seed 123 \
     --prefix $BASE_DIR/outputs/7_phylogeny/7_1_whg/snp_filterd_0.33_mac2_5kb_n


EOA



# ------------------------------------------------------------------------------
# Job 2

jobfile2=2_extractCOI.tmp # temp file
cat > $jobfile2 <<EOA # generate the job file
#!/bin/bash
#SBATCH --job-name=2_extractCOI
#SBATCH --partition=carl.p
#SBATCH --output=$BASE_DIR/logs/2_extractCOI_%A_%a.out
#SBATCH --error=$BASE_DIR/logs/2_extractCOI_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=04:00:00

vcftools \
    --gzvcf $BASE_DIR/outputs/6_genotyping/6_2_all/LG_M/filterd.all_sites.LG_M.vcf.gz \
    --chr LG_M \
    --from-bp 13393 \
    --to-bp 14044 \
    --recode \
    --stdout | gzip > $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd.vcf.gz


vcftools \
    --gzvcf $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd.vcf.gz \
    --max-missing 0.33 \
    --mac 2 \
#    --thin 5000 \
    --recode \
    --out $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd_0.33_mac2_5kb


vcf-to-tab < $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd_0.33_mac2_5kb.recode.vcf | sed -e 's/\.\/\./N\/N/g' -e 's/\.\//N\/N/g' -e 's/[ACGTN\*]\/\*/N\/N/g' > $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd_0.33_mac2_5kb.tab
   
perl $BASE_DIR/vcf_tab_to_fasta_alignment.pl -i $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd_0.33_mac2_5kb.tab > $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd_0.33_mac2_5kb.fas


EOA



# ------------------------------------------------------------------------------
# Job 3

jobfile3=3_COIraxml.tmp # temp file
cat > $jobfile3 <<EOA # generate the job file
#!/bin/bash
#SBATCH --job-name=3_COIraxml
#SBATCH --partition=carl.p
#SBATCH --output=$BASE_DIR/logs/3_COIraxml_%A_%a.out
#SBATCH --error=$BASE_DIR/logs/3_COIraxml_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=04:00:00


ml hpc-env/8.3 CMake/3.15.3-GCCcore-8.3.0 intel/2019b

# Reconstruct phylogeny
   # Note: number of invariant sites for Felsenstein correction was calculated as number of
   # variant sites in alignment (109,660) / genome-wide proportion of variant sites
   # (0.05) * genome-wide proportion of invariant sites (0.95)
   ~/apps/raxml-ng/bin/raxml-ng --all \
     --msa $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd_0.33_mac2_5kb.fas \
     --model GTR+G+ASC_FELS{2083540} \
     --tree pars{20},rand{20} \
     --bs-trees 100 \
     --threads 24 \
     --worker 4 \
     --seed 123 \
     --prefix $BASE_DIR/outputs/7_phylogeny/7_2_coi/coi_filterd_0.33_mac2_5kb


EOA



# ********** Schedule the job launching ***********
# -------------------------------------------------

if [ "$JID_RES" = "jid1" ] || [ "$JID_RES" = "jid2"] || [ "$JID_RES" = "jid3" ];
then
  echo "*****   0_filter         : DONE         **"
else
  jid0=$(sbatch ${jobfile0})
fi


if [ "$JID_RES" = "jid2" ] || [ "$JID_RES" = "jid3" ];
then
  echo "*****   1_raxml         : DONE         **"
elif [ "$JID_RES" = jid1 ]
then
  jid1=$(sbatch ${jobfile1})
else      
  jid1=$(sbatch --dependency=afterok:${jid0##* } ${jobfile1})
fi


if [ "$JID_RES" = "jid3" ];
then
  echo "*****   2_extractCOI    : DONE         **"
elif [ "$JID_RES" = jid2 ]
then
  jid2=$(sbatch ${jobfile2})
else
  jid2=$(sbatch --dependency=afterok:${jid1##* } ${jobfile2})
fi


if [ "$JID_RES" = "jid3" ];
then
  jid3=$(sbatch ${jobfile3})
else
  jid3=$(sbatch --dependency=afterok:${jid2##* } ${jobfile3})
fi

