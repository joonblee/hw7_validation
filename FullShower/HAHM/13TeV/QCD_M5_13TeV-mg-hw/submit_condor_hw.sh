#!/bin/bash

SAMPLES=("Pt-65To70_1459323" "Pt-70To75_1459324" "Pt-75To80_1459325" "Pt-80To90_1459326" "Pt-90To100_1459327" "Pt-100To120_1459328" "Pt-120To150_1459329" "Pt-150To9999_1459330")

zpmass=5
coupling="0.05"

cat <<EOT > submit_condor_hw.txt
universe        = vanilla
executable      = hw_condor.sh
arguments       = \$(Cluster) \$(Process) \$(sample) \$(zpmass) \$(coupling)
output          = joblog/job.\$(Cluster).\$(Process).out
error           = joblog/job.\$(Cluster).\$(Process).err
log             = joblog/job.log
+SingularityImage = "/data6/Users/taehee/herwig_sandbox"
+SingularityBind  = "/data6/Users/taehee/HerwigWD:/data6/Users/taehee/HerwigWD"
stream_output = True
stream_error = True
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
done
