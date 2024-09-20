#!/bin/bash

#ptbin=(50 80 120 170 300 470 600 800 1000 9999)
#ptbin=(50 60 70 80 100 120 150 190 240 300 9999)

cat <<EOT > submit_condor_mg.txt
universe        = vanilla
executable      = mg_condor.sh
arguments       = \$(Cluster) \$(Process) \$(ptj) \$(maxptj)
output          = job.\$(Cluster).\$(Process).out
error           = job.\$(Cluster).\$(Process).err
log             = job.\$(Cluster).\$(Process).log
+SingularityImage = "/data6/Users/taehee/herwig_sandbox"
+SingularityBind = "/data6/Users/taehee/HerwigWD:/data6/Users/taehee/HerewigWD"

queue 100
EOT

for ((i=0; i<${#ptbin[@]}-1; i++)); do
    ptj=${ptbin[i]}
    maxptj=${ptbin[i+1]}
    echo "Submitting job for MG ptbinned [$ptj, $maxptj]"
    condor_submit submit_condor_mg.txt -append "arguments = \$(Cluster) \$(Process) $ptj $maxptj"
    sleep 60
done
