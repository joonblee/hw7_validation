#!/bin/bash

ptbin=(65 70 75 80 90 100 120 150 9999)

zpmass=5

cat <<EOT > submit_condor_mg.txt
universe        = vanilla
executable      = mg_condor.sh
arguments       = \$(Cluster) \$(Process) \$(ptj) \$(ptjmax) \$(zpmass)
output          = joblog/job.\$(Cluster).\$(Process).out
error           = joblog/job.\$(Cluster).\$(Process).err
log             = joblog/job.log
+SingularityImage = "/data6/Users/taehee/Herwig/herwig_sandbox"
+SingularityBind = "/data6/Users/taehee/Herwig/HerwigWD:/data6/Users/taehee/Herwig/HerewigWD"
should_transfer_files = YES
EOT

for ((i=0; i<${#ptbin[@]}-1; i++)); do
    ptj=${ptbin[i]}
    ptjmax=${ptbin[i+1]}
    queue=${queues[i]}
    queue=10
    echo "Submitting job for MG ptbinned [$ptj, $ptjmax] with Zprime mass $zpmass"
    condor_submit submit_condor_mg.txt \
    -append "arguments = \$(Cluster) \$(Process) $ptj $ptjmax $zpmass" \
    -append "queue $queue"
done
