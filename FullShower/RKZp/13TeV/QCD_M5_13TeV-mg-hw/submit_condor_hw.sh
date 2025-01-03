#!/bin/bash

SAMPLES=("Pt-65To70_1777823" "Pt-70To75_1777824" "Pt-75To80_1777825" "Pt-80To90_1777826" "Pt-90To100_1777827" "Pt-100To120_1777828" "Pt-120To150_1777829" "Pt-150To9999_1777830")

zpmass=5
coupling="0.05"

cat <<EOT > submit_condor_hw.txt
universe        = vanilla
executable      = hw_condor.sh
arguments       = \$(Cluster) \$(Process) \$(sample) \$(zpmass) \$(coupling)
output          = joblog/job.\$(Cluster).\$(Process).out
error           = joblog/job.\$(Cluster).\$(Process).err
log             = joblog/job.\$(Cluster).\$(Process).log
+SingularityImage = "/data6/Users/taehee/Herwig/herwig_sandbox"
+SingularityBind  = "/data6/Users/taehee/Herwig/HerwigWD:/data6/Users/taehee/Herwig/HerwigWD,/data9/Users/taehee/SampleProduction/HerwigSample/tmp:/data9/Users/taehee/SampleProduction/HerwigSample/tmp/"
stream_output = True
stream_error = True
should_transfer_files = YES
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
    sleep 3
done
