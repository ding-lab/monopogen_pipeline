#!/bin/bash

# Perform contig separation and read filtering

# Configuration
source config.ini

# ******************
# Command line

BATCH="$1"
CMD="$2"
# ******************

BAMLIST=bamlist.${BATCH}

if [[ "$CMD" == "preprocess" ]] ; then
    mkdir -p ${FB_SCRATCHDIR}

    LSF_OUTDIR=${MYSTORAGE}/LSF_logs/${STUDY}/preprocess
    mkdir -p ${LSF_OUTDIR}
    LSF_STDOUT=${LSF_OUTDIR}/preprocess.${BATCH}.stdout
    LSF_STDERR=${LSF_OUTDIR}/preprocess.${BATCH}.stderr

    bsub -n ${NCPU_PREPROC} -J preproc.${BATCH} -g /${USER}/${LABNAME} -q ${QNAME} -R 'rusage[mem=32GB] span[hosts=1]' -a "docker(${IMAGE})" -o ${LSF_STDOUT}  -e ${LSF_STDERR}  "python  ${INSTALL_PATH}/src/Monopogen.py  preProcess -b ${BAMLIST} -o ${FB_SCRATCHDIR}/out.${BATCH} -a ${INSTALL_PATH}/apps -t ${NCPU_PREPROC}"

    echo stuff -a "docker(${IMAGE})"

elif [[ "$CMD" == "move" ]] ; then

    mkdir -p ${FB_STORAGEDIR}
    rsync -rlHtpgP --exclude '*.bam.lst' ${FB_SCRATCHDIR}/out.${BATCH}  ${FB_STORAGEDIR}

elif [[ "$CMD" == "tidy" ]] ; then

    rm -rf  ${FB_SCRATCHDIR}/out.${BATCH}
else
    echo Command ${CMD} is unrecognized. Exiting...
fi
