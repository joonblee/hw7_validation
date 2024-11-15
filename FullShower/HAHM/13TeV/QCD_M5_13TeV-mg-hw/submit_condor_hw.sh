#!/bin/bash

SAMPLES=("Pt-60To65_1366782" "Pt-65To70_1366783" "Pt-70To75_1366784" "Pt-75To80_1366785" "Pt-80To85_1366786" "Pt-85To90_1366787" "Pt-90To100_1366788" "Pt-100To140_1366789" "Pt-140To200_1366790" "Pt-200To9999_1366792")

zpmass=5
coupling="0.05"

cat <<EOT > submit_condor_hw.txt
universe        = vanilla
executable      = hw_condor.sh
arguments       = \$(Cluster) \$(Process) \$(sample) \$(zpmass) \$(coupling)
output          = job.\$(Cluster).\$(Process).out
error           = job.\$(Cluster).\$(Process).err
log             = job.\$(Cluster).\$(Process).log
+SingularityImage = "/data6/Users/taehee/herwig_sandbox"
+SingularityBind  = "/data6/Users/taehee/HerwigWD:/data6/Users/taehee/HerwigWD"
EOT

# Loop through the array and submit jobs with adjacent elements
for ((i=0; i<${#SAMPLES[@]}; i++)); do
    sample=${SAMPLES[i]}
    queue=$(ls /gv0/Users/taehee/HerwigSample/mg/MZp-$zpmass/$sample | wc -l)
    echo "Submitting job for HW with MG job number $sample with Zprime mass $zpmass, coupling $coupling"
    condor_submit submit_condor_hw.txt \
    -append "arguments = \$(Cluster) \$(Process) $sample $zpmass $coupling" \
    -append "JobBatchName = MZp-"$zpmass"_"$sample \
    -append "queue $queue"
    sleep 5
done
