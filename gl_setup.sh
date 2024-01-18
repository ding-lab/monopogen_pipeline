#!/bin/bash

# Perform setup step for germline

# Configuration
source config.ini

# ******************
# Passed parameters

BATCH="$1"
# ******************

BAMLIST=bamlist.${BATCH}
BATCHCMDS=${RS_STORAGEDIR}/batch_run.${BATCH}
filtered_bam_source_dir=${FB_STORAGEDIR}/out.${BATCH}/Bam

mkdir -p $(dirname ${BATCHCMDS})

# loop over samples
for s in $(grep -v ^# ${BAMLIST} | cut -d, -f 1 - ); do
    
    DESTDIR=${SAMP_SCRATCHDIR}/samples.${BATCH}/${s}
    mkdir -p ${DESTDIR}/Bam

    # Create lists
    for c in $(seq 1 22) ; do
        echo ${filtered_bam_source_dir}/${s}_chr${c}.filter.bam  > ${DESTDIR}/Bam/chr${c}.filter.bam.lst
        REGION=${DESTDIR}/Bam/chr${c}.region.lst
        echo chr${c}  > ${REGION}
    done
    
    # Create run scripts (keep loop separate or else it fails)
    for c in $(seq 1 22) ; do
        REGION=${DESTDIR}/Bam/chr${c}.region.lst
	
        python  ${INSTALL_PATH}/src/Monopogen.py  germline  \
	    -a  ${INSTALL_PATH}/apps -t 1   -r  ${REGION} \
	    -p  ${REF_DIR}/1KG3_imputation_panel/ \
	    -g  ${REF_DIR}/GRCh38.d1.vd1/GRCh38.d1.vd1.fa   \
	    -m 3 -s all -o  ${DESTDIR} --norun TRUE
    done
    
    # Patch scripts due to bcftools issue (have needed only for chr3 so far)
    for c in $(seq 1 22) ; do
        sed -i 's/bcftools\ norm/bcftools\ norm\ \-c\ s/' ${DESTDIR}/Script/runGermline_chr${c}.sh
    done
    
    # Create logs
    LOGDIR=${DESTDIR}/mylogs
    mkdir -p ${LOGDIR}

    # Generate all commands (not used for batch queues)
    for c in $(seq 1 22) ; do
        myscript=${DESTDIR}/Script/runGermline_chr${c}.sh
        mylog=${DESTDIR}/mylogs/runGermline_chr${c}.log
        echo "bash ${myscript} >& ${mylog}"
    done >> ${BATCHCMDS}
    
done
