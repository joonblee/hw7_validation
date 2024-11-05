#!/bin/bash

process=${1}
sample=${2}
campaign=${3}

RUNS=("GEN" "SIM" "DIGIPremix" "HLT" "RECO" "MiniAODv2")
CMSSW=("CMSSW_10_6_30_patch1" "CMSSW_10_6_17_patch1" "CMSSW_10_6_17_patch1" "CMSSW_8_0_33_UL" "CMSSW_10_6_17_patch1" "CMSSW_10_6_25")

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc700

WD="/data6/Users/taehee/HerwigWD/hw7_validation/FullShower/HAHM/13TeV/SampleGeneration"
outputdir="\/gv0\/Users\/taehee\/HerwigSample"
mkdir -p /gv0/Users/taehee/HerwigSample/samples/${campaign}/${sample}
mkdir -p tmp/${campaign}/${sample}

for ((i = 0; i < ${#RUNS[@]}; i++)); do
    output=${RUNS[$i]}
    if [ -s "/gv0/Users/taehee/HerwigSample/samples/${campaign}/${sample}/${output}_${process}.root" ];then
        echo "/gv0/Users/taehee/HerwigSample/samples/${campaign}/${sample}/${output}_${process}.root: File exists... pass"
        continue
    fi
    
    if [[ $output != "GEN" ]]; then
        input=${RUNS[$((i-1))]}
    fi
    cd /data9/Users/taehee/${CMSSW[$i]}/src
    eval `scram runtime -sh`
    scram b
    cd $WD
    sed -e "s/__OUTPUT__/${outputdir}\/samples\/${campaign}\/${sample}\/${output}_${process}/g" "files_cfg/${campaign}${output}_cfg.py" > "tmp/${campaign}/${sample}/${output}_${process}.py"
    if [[ $output == "GEN" ]]; then
        sed -i "s/__INPUT__/${outputdir}\/hw\/${sample}\/$process\/LHC/g" "tmp/${campaign}/${sample}/${output}_${process}.py"
        sed -i "s/__RANDOM__/${process}/g" "tmp/${campaign}/${sample}/${output}_${process}.py"
    else
        sed -i "s/__INPUT__/${outputdir}\/samples\/${campaign}\/${sample}\/${input}_${process}/g" "tmp/${campaign}/${sample}/${output}_${process}.py"
    fi
    cmsRun tmp/${campaign}/${sample}/${output}_${process}.py &> tmp/${campaign}/${sample}/${output}_${process}.log

done
