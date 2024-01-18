# monopogen_pipeline

This is a local implementation of the Monopogen analysis package, originally developed and maintained by [Ken chen's lab](https://sites.google.com/view/kchenlab/Home).

These scripts were developed around the idea of using sample batches, each of which is associated with an alphanumeric tag (e.g., 00, 01, 02). They are set up for LSF batch queues with access to global scratch and should be portable between users. The directory structure is based partly on third-party expectations and, of course, on design choices, which may not be optimal for everyone.

### Setup
1. Clone this repository and customize the user configuration in the `config.ini` file. `${TOPDIR}/` is where software, reference, and data directories live. Assemble a list of bams into a CSV file (e.g., `batch.test1`) in the format
    ```
    <unique_bam_tag_1>,<bam_path_1>
    <unique_bam_tag_2>,<bam_path_2>
    ...
    ```	
    Place this file at the top level in this cloned repo.

2. Install Monopogen into `${TOPDIR}/software/Monopogen/`. We opted to place the reference files into `${TOPDIR}/${STUDY}/reference/`, namely:
    * `${TOPDIR}/${STUDY}/reference/1KG3_imputation_panel/`
    * `${TOPDIR}/${STUDY}/reference/GRCh38.d1.vd1/`

3. For LSF use, create and/or modify the job group under which the scripts will be run. (Here, we use `/${USER}/${LABNAME}`, where `${USER}` and `${LABNAME}` are set in `config.ini`.)

### Germline pipeline
* **Raw calling.** Run each step sequentially. Note that *move* may be run concurrently with *preprocess*, *run*, or *merge*, but final *move* should be issued.
    ```
    BATCH=test1
    ./1.prepare.sh  ${BATCH}  preprocess
    ./1.prepare.sh  ${BATCH}  move
    ./1.prepare.sh  ${BATCH}  tidy

    ./2.germline.sh  ${BATCH}  setup
    ./2.germline.sh  ${BATCH}  run
    ./2.germline.sh  ${BATCH}  merge
    ./2.germline.sh  ${BATCH}  move
    ./2.germline.sh  ${BATCH}  tidy
   ```
   The final raw calls are in `${TOPDIR}/samples/samples.${BATCH}/${SAMPLE}/germline/merged/${SAMPLE}.phased.sorted.vcf.gz`.

* **Annotation.**

* **Cell type mapping.**
