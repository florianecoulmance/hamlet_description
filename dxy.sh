#!/bin/bash
# by: Floriane Coulmance: 27/10/2021
# usage:
# gxp.sh -i <PATH> -j <JOB_ID>
# ------------------------------------------------------------------------------
# PATH corresponds to the path to the base directory, all outputs and necessary
# folder will be created by the script
# JOB_ID corresponds string ids from where you want  the script to be ran
# ------------------------------------------------------------------------------



# ********** Allow to enter bash options **********
# -------------------------------------------------

while getopts i:j:k: option
do
case "${option}"
in
i) BASE_DIR=${OPTARG};; # get the base directory path
j) JID_RES=${OPTARG};; # get the jobid from which you want to resume
esac
done



# ********* Create necessary repositories *********
# -------------------------------------------------

# Repo for gxp outputs
mkdir $BASE_DIR/outputs/8_dxy/



# ********* Jobs creation *************************
# -------------------------------------------------

# ------------------------------------------------------------------------------
# Job 0 

jobfile0=0_vcftogeno.tmp # temp file
cat > $jobfile0 <<EOA # generate the job file
#!/bin/bash
#SBATCH --job-name=0_vcftogeno
#SBATCH --partition=carl.p
#SBATCH --array=0-23
#SBATCH --output=$BASE_DIR/logs/0_vcftogeno_%A_%a.out
#SBATCH --error=$BASE_DIR/logs/0_vcftogeno_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=02:30:00


list=(01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24)
echo \${list[*]}

NB=\${list[\${SLURM_ARRAY_TASK_ID}]}
echo \${NB}


INPUT_VCF=$BASE_DIR/outputs/6_genotyping/6_2_all/filterd.allBP.vcf.gz

vcftools --gzvcf \${INPUT_VCF} \
    --chr LG\${NB} \
    --recode \
    --stdout | bgzip  > $BASE_DIR/outputs/8_dxy/allBP.LG\${NB}.vcf.gz

python /user/doau0129/work/software/genomics_general/VCF_processing/parseVCF.py \
    -i $BASE_DIR/outputs/8_dxy/allBP.LG\${NB}.vcf.gz  | gzip > $BASE_DIR/outputs/8_dxy/allBP.LG\${NB}.geno.gz

ls -1 $BASE_DIR/outputs/8_dxy/*.geno.gz > $BASE_DIR/outputs/lof/dxy_geno.fofn



EOA



# ------------------------------------------------------------------------------
# Job 1 

jobfile1=1_dxy_ch.tmp # temp file
cat > $jobfile1 <<EOA # generate the job file
#!/bin/bash
#SBATCH --job-name=1_dxy_ch
#SBATCH --partition=carl.p
#SBATCH --array=1-24
#SBATCH --output=$BASE_DIR/logs/1_dxy_ch_%A_%a.out
#SBATCH --error=$BASE_DIR/logs/1_dxy_ch_%A_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=02:30:00


INPUT_GENO=$BASE_DIR/outputs/lof/dxy_geno.fofn
echo \${INPUT_GENO}

GENO=\$(cat \${INPUT_GENO} | head -n \${SLURM_ARRAY_TASK_ID} | tail -n 1)
echo \${GENO}

list0=(01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24)
echo \${list0[*]}

NB=\${list0[\${SLURM_ARRAY_TASK_ID}-1]}
echo \${NB}

list=(nigpan-puepan nigpan-abepan nigpan-tanpan nigpan-unipan nigpan-gumpan tanpan-abepan tanpan-puepan tanpan-unipan tanpan-gumpan abepan-puepan abepan-unipan abepan-gumpan puepan-unipan puepan-gumpan unipan-gumpan)
echo \${list[*]}


zcat \${GENO} | \
    head -n 1 | \
    cut -f 3- | \
    sed 's/\\t/\\n/g' | \
    awk -v OFS='\\t' '{print \$1, substr( \$1, length(\$1) - 5, 6)}' > pop.txt


for k in \${list}; do
    echo \${k}
    echo \${list[\${k}][1,6]}
    echo \${list[\${k}][8,13]}

    python /user/doau0129/work/software/genomics_general/popgenWindows.py \
        -w 50000 -s 5000 \
        --popsFile pop.txt \
        -p \${list[\${k}][1,6]} -p \${list[\${k}][8,13]} \
        -g \${GENO} \
        -o $BASE_DIR/outputs/8_dxy/dxy.\${list[\${k}][1,6]}-\${list[\${k}][8,13]}.LG\${NB}.50kb-5kb.txt.gz \
        -f phased \
        --writeFailedWindows \
        -T 1
        
done


EOA



# ********** Schedule the job launching ***********
# -------------------------------------------------

if [ "$JID_RES" = "jid1" ] || [ "$JID_RES" = "jid2" ] || [ "$JID_RES" = "jid3" ] || [ "$JID_RES" = "jid4" ] || [ "$JID_RES" = "jid5" ];
then
  echo "*****   0_vcftogeno     : DONE         **"
else
  jid0=$(sbatch ${jobfile0})
fi


if [ "$JID_RES" = "jid2" ] || [ "$JID_RES" = "jid3" ] || [ "$JID_RES" = "jid4" ] || [ "$JID_RES" = "jid5" ];
then
  echo "*****   1_dxy_ch        : DONE         **"
elif [ "$JID_RES" = jid1 ]
then
  jid1=$(sbatch ${jobfile1})
else
  jid1=$(sbatch --dependency=afterok:${jid0##* } ${jobfile1})
fi

