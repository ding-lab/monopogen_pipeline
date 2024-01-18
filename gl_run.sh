#!/bin/bash

# Configuration
source config.ini

# ******************
# Command line

SCRIPT="$1"
LOGFILE="$2"
# ******************

# Run
bash ${SCRIPT} >& ${LOGFILE}
