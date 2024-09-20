#!/bin/bash

#mg_job_numbers=("2491183_50_80" "2491184_80_120" "2491185_120_170" "2491186_170_300" "2491187_300_470" "2491188_470_600" "2491189_600_800" "2491190_800_1000" "2491191_1000_9999")

cat <<EOT > submit_condor_hw.txt
universe        = vanilla
executable      = hw_condor.sh
arguments       = \$(Cluster) \$(Process) \$(mg_job_number)
output          = job.\$(Cluster).\$(Process).out
error           = job.\$(Cluster).\$(Process).err
log             = job.\$(Cluster).\$(Process).log
+SingularityImage = "/data6/Users/taehee/herwig_sandbox"
+SingularityBind  = "/data6/Users/taehee/HerwigWD:/data6/Users/taehee/HerwigWD"

queue 100
EOT

# Loop through the array and submit jobs with adjacent elements
for ((i=0; i<${#mg_job_numbers[@]}; i++)); do
    mg_job_number=${mg_job_numbers[i]}
    echo "Submitting job for HW with MG job number $mg_job_number"
    condor_submit submit_condor_hw.txt -append "arguments = \$(Cluster) \$(Process) $mg_job_number"
    sleep 60
done
