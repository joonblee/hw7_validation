#!/bin/bash

#samples=("2491183_50_80" "2491184_80_120" "2491185_120_170" "2491186_170_300" "2491187_300_470" "2491188_470_600" "2491189_600_800" "2491190_800_1000" "2491191_1000_9999")
#samples=("2491562_50_60" "2491563_60_70" "2491565_70_80" "2491566_80_100" "2491573_100_120")
samples=("1147856_120_150" "1147857_150_190" "1147858_190_240" "1147859_240_300" "1147860_300_9999")

cat <<EOT > submit_condor.txt
universe        = vanilla
executable      = condor.sh
arguments       = \$(Process) \$(sample)
output          = job.\$(Cluster).\$(Process).out
error           = job.\$(Cluster).\$(Process).err
log             = job.\$(Cluster).\$(Process).log
queue 100
EOT

# Loop through the array and submit jobs with adjacent elements
for ((i=0; i<${#samples[@]}; i++)); do
    sample=${samples[i]}
    echo "Submitting job for sample production: $sample"
    condor_submit submit_condor.txt -append "arguments = \$(Process) $sample"
done
