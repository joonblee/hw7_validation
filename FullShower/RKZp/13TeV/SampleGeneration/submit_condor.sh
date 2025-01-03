#!/bin/bash

SAMPLES=("Pt-90To95_2213047" "Pt-100To110_2213049" "Pt-110To120_2213050" "Pt-120To130_2213051" "Pt-130To150_2213052" "Pt-150To200_2213053" "Pt-200To9999_2213054")

campaign="RunIISummer20UL16"
# "RunIISummer20UL16" "RunIISummer20UL16APV" "RunIISummer20UL17" "RunIISummer20UL18"

zpmass=20
coupling="0p1"

cat <<EOT > submit_condor.jds
universe        = vanilla
executable      = condor.sh
arguments       = \$(Process) \$(sample) \$(campaign) \$(zpmass) \$(coupling)
output          = joblog/job.\$(Cluster).\$(Process).out
error           = joblog/job.\$(Cluster).\$(Process).err
log             = joblog/job.\$(Cluster).\$(Process).log
x509userproxy   = /tmp/x509up_u5592
EOT

for ((i=0; i<${#SAMPLES[@]}; i++)); do
    sample=${SAMPLES[i]}
    queue=$(ls /gv0/Users/taehee/HerwigSample/hw/MZp-$zpmass/gbb-$coupling/$sample | wc -l)
    echo "Submitting job for sample production: MZp-$zpmass"_"$sample"
    condor_submit submit_condor.jds \
        -append "arguments = \$(Process) $sample $campaign $zpmass $coupling" \
        -append "JobBatchName = SAMPLE_MZp-$zpmass"_"$sample" \
        -append "queue $queue"
done
