#!/bin/bash

ptbin=(90 95 100 110 120 130 150 200 9999)

zpmass=10

cat <<EOT > submit_condor_mg.txt
universe        = vanilla
executable      = mg_condor.sh
arguments       = \$(Cluster) \$(Process) \$(ptj) \$(ptjmax) \$(zpmass)
output          = joblog/job.\$(Cluster).\$(Process).out
error           = joblog/job.\$(Cluster).\$(Process).err
log             = joblog/job.\$(Cluster).\$(Process).log
+SingularityImage = "/data6/Users/taehee/Herwig/herwig_sandbox"
+SingularityBind = "/data6/Users/taehee/Herwig/HerwigWD:/data6/Users/taehee/Herwig/HerewigWD"
should_transfer_files = YES
getenv = True
EOT

for ((i=0; i<${#ptbin[@]}-1; i++)); do
    ptj=${ptbin[i]}
    ptjmax=${ptbin[i+1]}
    queue=${queues[i]}
    queue=1
    echo "Submitting job for MG ptbinned [$ptj, $ptjmax] with Zprime mass $zpmass"
    condor_submit submit_condor_mg.txt \
    -append "arguments = \$(Cluster) \$(Process) $ptj $ptjmax $zpmass" \
    -append "JobBatchName = Pt-${ptj}To${ptjmax}_\$(Cluster)" \
    -append "queue $queue"
    sleep 3
done
