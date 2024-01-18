#!/bin/bash

# Configuration
source config.ini

# ******************
# Passed parameters

VCFDIR="$1"
SAMPLE="$2"
# ******************

# setup tools
picard=${INSTALL_PATH}/apps/picard.jar
bcftools=${INSTALL_PATH}/apps/bcftools

cd ${VCFDIR}

mkdir -p merged
rm -f merged/*vcf.gz

# Create index
for c in $(seq 1 22); do
    if [ ! -f chr${c}.gl.vcf.gz.tbi ] ; then
	${bcftools} index -f -o    chr${c}.gl.vcf.gz.tbi       chr${c}.gl.vcf.gz
    fi
    if [ ! -f chr${c}.phased.vcf.gz.tbi ] ; then
	${bcftools} index -f -o    chr${c}.phased.vcf.gz.tbi   chr${c}.phased.vcf.gz
    fi
done
	
${bcftools} concat -a  -O z  -o  merged/all.phased.vcf.gz chr1.phased.vcf.gz chr2.phased.vcf.gz chr3.phased.vcf.gz chr4.phased.vcf.gz \
    chr5.phased.vcf.gz chr6.phased.vcf.gz chr7.phased.vcf.gz chr8.phased.vcf.gz chr9.phased.vcf.gz chr10.phased.vcf.gz \
    chr11.phased.vcf.gz chr12.phased.vcf.gz chr13.phased.vcf.gz chr14.phased.vcf.gz chr15.phased.vcf.gz chr16.phased.vcf.gz \
    chr17.phased.vcf.gz chr18.phased.vcf.gz chr19.phased.vcf.gz chr20.phased.vcf.gz chr21.phased.vcf.gz chr22.phased.vcf.gz
    
SORTTMP=${STUDY_SCRATCHDIR}/tmp/bcftools-sort.$(cat /dev/urandom | tr -c -d 'A-Za-z0-9' | fold -w 10 | head -n 1)
mkdir -p ${SORTTMP}

${bcftools} sort -m 24G  -T ${SORTTMP}   -O z -o merged/${SAMPLE}.phased.sorted.vcf.gz  merged/all.phased.vcf.gz
${bcftools} index  -o merged/${SAMPLE}.phased.sorted.vcf.gz.tbi  merged/${SAMPLE}.phased.sorted.vcf.gz

# clean up
rm -f merged/all.phased.vcf.gz
rm -rf ${SORTTMP}
