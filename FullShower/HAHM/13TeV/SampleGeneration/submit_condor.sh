#!/bin/bash

SAMPLES=("M-50_Pt-300To320_1317762" "M-50_Pt-320To340_1317763")

campaign="RunIISummer20UL16"
# "RunIISummer20UL16" "RunIISummer20UL16APV" "RunIISummer20UL17" "RunIISummer20UL18"

cat <<EOT > submit_condor.jds
universe        = vanilla
executable      = condor.sh
arguments       = \$(Process) \$(sample) \$(campaign)
output          = job.\$(Cluster).\$(Process).out
error           = job.\$(Cluster).\$(Process).err
log             = job.\$(Cluster).\$(Process).log
x509userproxy   = /tmp/x509up_u5592
EOT

for ((i=0; i<${#SAMPLES[@]}; i++)); do
    sample=${SAMPLES[i]}
    queue=$(ls /gv0/Users/taehee/HerwigSample/hw/$sample | wc -l)
    echo "Submitting job for sample production: $sample"
    condor_submit submit_condor.jds \
        -append "arguments = \$(Process) $sample $campaign" \
        -append "JobBatchName = SAMPLE_$sample" \
        -append "queue $queue"
done
