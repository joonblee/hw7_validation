#!/bin/bash

process=${1}
sample=${2}

RUNS=("GEN")
CMSSW=("CMSSW_10_6_19_patch3")

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc700

WD="/data6/Users/taehee/HerwigWD/hw7_validation/FullShower/HAHM/13TeV/SampleGeneration"
cd $WD
outputdir="\/gv0\/Users\/taehee\/HerwigSample\/$sample"
mkdir -p /gv0/Users/taehee/HerwigSample/$sample
mkdir -p tmp/$sample

for ((i = 0; i < ${#RUNS[@]}; i++)); do
    output=${RUNS[$i]}
    if [[ $output != "GEN" ]]; then
        input=${RUNS[$((i-1))]}
    fi
    cd /data9/Users/taehee/${CMSSW[$i]}/src
    eval `scram runtime -sh`
    scram b
    cd $WD

    sed -e "s/__OUTPUT__/$outputdir\/${output}_${process}/g" "files/${output}.py" > "tmp/$sample/${output}_${process}.py"
    if [[ $output == "GEN" ]]; then
        sed -i "s/__INPUT__/\/gv0\/Users\/taehee\/HerwigSample\/hw\/$sample\/$process\/LHC/g" "tmp/$sample/${output}_${process}.py"
        sed -i "s/__RANDOM__/${process}/g" "tmp/$sample/${output}_${process}.py"
    else
        sed -i "s/__INPUT__/$outputdir\/${input}_${process}/g" "tmp/$sample/${output}_${process}.py"
    fi
    cmsRun tmp/$sample/${output}_${process}.py &> tmp/$sample/${output}_${process}.log
    echo "Running $sample/${output}_${process}..."

done
