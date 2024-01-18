#!/bin/bash

# Perform germline calling by sample/contig

# Configuration
source config.ini

# ******************
# Command line

BATCH="$1"
CMD="$2"
# ******************

BAMLIST=bamlist.${BATCH}

if [[ "$CMD" == "setup" ]] ; then 

    # Create job
    LSF_OUTDIR=${MYSTORAGE}/LSF_logs/${STUDY}/germline_setup
    mkdir -p ${LSF_OUTDIR}
    LSF_STDOUT=${LSF_OUTDIR}/batch_${BATCH}.stdout
    LSF_STDERR=${LSF_OUTDIR}/batch_${BATCH}.stderr
    bsub -n 1 -J gl_setup.${BATCH} -g /${USER}/${LABNAME} -q ${QNAME} -R 'rusage[mem=16GB] span[hosts=1]' -a "docker(${IMAGE})" -o ${LSF_STDOUT}  -e ${LSF_STDERR} "./gl_setup.sh ${BATCH}"

elif [[ "$CMD" == "run" ]] ; then 

    # Generate each command and submit
    for samp in $(grep -v ^# ${BAMLIST}  | cut -d, -f1 ) ; do
	echo ""
	echo "======== ${samp} ======="

	DESTDIR=${SAMP_SCRATCHDIR}/samples.${BATCH}/${samp}

	for c in $(seq 1 22) ; do
            myscript=${DESTDIR}/Script/runGermline_chr${c}.sh
            mylog=${DESTDIR}/mylogs/runGermline_chr${c}.log
	    mkdir -p ${DESTDIR}/mylogs
	    
	    LSF_OUTDIR=${MYSTORAGE}/LSF_logs/${STUDY}/germline_run/samples.${BATCH}
	    mkdir -p ${LSF_OUTDIR}
	    LSF_STDOUT=${LSF_OUTDIR}/${samp}.chr${c}.stdout
	    LSF_STDERR=${LSF_OUTDIR}/${samp}.chr${c}.stderr
	    bsub -n 1 -J gl_run.${BATCH}.${samp}.chr${c} -g /${USER}/${LABNAME} -q ${QNAME} -R 'rusage[mem=32GB] span[hosts=1]' -a "docker(${IMAGE})" -o ${LSF_STDOUT}  -e ${LSF_STDERR}  "./gl_run.sh ${myscript}  ${mylog}"
	done
    done
    
elif [[ "$CMD" == "merge" ]] ; then

    for samp in $(grep -v ^# ${BAMLIST}  | cut -d, -f1 ) ; do

	LSF_OUTDIR=${MYSTORAGE}/LSF_logs/${STUDY}/germline_merge/merge.${BATCH}
	mkdir -p ${LSF_OUTDIR}
	LSF_STDOUT=${LSF_OUTDIR}/${samp}.stdout
	LSF_STDERR=${LSF_OUTDIR}/${samp}.stderr
	
	VCFDIR=${SAMP_SCRATCHDIR}/samples.${BATCH}/${samp}/germline

	bsub -n 1 -J gl_merge.${BATCH}.${samp} -g /${USER}/${LABNAME} -q ${QNAME} -R 'rusage[mem=32GB] span[hosts=1]' -a "docker(${IMAGE})" -o ${LSF_STDOUT}  -e ${LSF_STDERR}  "./gl_merge_phased.sh  ${VCFDIR} ${samp}"

    done

elif [[ "$CMD" == "move" ]] ; then

    mkdir -p ${SAMP_STORAGEDIR}/samples.${BATCH}
    for samp in $(grep -v ^# ${BAMLIST} | cut -d, -f1 ) ; do
	echo ${samp}
	# Copy all
	rsync -rlHtpgP  ${SAMP_SCRATCHDIR}/samples.${BATCH}/${samp}    ${SAMP_STORAGEDIR}/samples.${BATCH}
    done

elif [[ "$CMD" == "tidy" ]] ; then

    for samp in $(grep -v ^# ${BAMLIST} | cut -d, -f1 ) ; do
	echo Removing ${SAMP_SCRATCHDIR}/samples.${BATCH}/${samp}/
	rm -rf ${SAMP_SCRATCHDIR}/samples.${BATCH}/${samp}/
    done

else
    echo Command ${CMD} is unrecognized. Exiting...
fi
