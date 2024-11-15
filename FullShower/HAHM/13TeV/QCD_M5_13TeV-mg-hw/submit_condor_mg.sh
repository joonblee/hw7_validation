#!/bin/bash

ptbin=(65 70 75 80 85 90 100 140 200 9999)
queues=(317 153 76 39 20 37 69 36 0)

zpmass=5

cat <<EOT > submit_condor_mg.txt
universe        = vanilla
executable      = mg_condor.sh
arguments       = \$(Cluster) \$(Process) \$(ptj) \$(ptjmax) \$(zpmass)
output          = job.\$(Cluster).\$(Process).out
error           = job.\$(Cluster).\$(Process).err
log             = job.\$(Cluster).\$(Process).log
+SingularityImage = "/data6/Users/taehee/herwig_sandbox"
+SingularityBind = "/data6/Users/taehee/HerwigWD:/data6/Users/taehee/HerewigWD"
should_transfer_files = YES
EOT

for ((i=0; i<${#ptbin[@]}-1; i++)); do
    ptj=${ptbin[i]}
    ptjmax=${ptbin[i+1]}
    queue=${queues[i]}
    #queue=30
    echo "Submitting job for MG ptbinned [$ptj, $ptjmax] with Zprime mass $zpmass"
    condor_submit submit_condor_mg.txt \
    -append "arguments = \$(Cluster) \$(Process) $ptj $ptjmax $zpmass" \
    -append "queue $queue"
done
