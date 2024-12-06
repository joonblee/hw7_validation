#!/bin/bash

process=${1}
sample=${2}
campaign=${3}
zpmass=${4}

if [ "$campaign" == "RunIISummer20UL16" ]; then
    CMSSW=("CMSSW_10_6_19_patch3" "CMSSW_10_6_17_patch1" "CMSSW_10_6_17_patch1" "CMSSW_8_0_36_UL_patch1" "CMSSW_10_6_17_patch1" "CMSSW_10_6_25")
elif [ "$campaign" == "RunIISummer20UL16APV" ]; then
    CMSSW=("CMSSW_10_6_19_patch3" "CMSSW_10_6_17_patch1" "CMSSW_10_6_17_patch1" "CMSSW_8_0_36_UL_patch1" "CMSSW_10_6_17_patch1" "CMSSW_10_6_25")
elif [ "$campaign" == "RunIISummer20UL17" ]; then
    CMSSW=("CMSSW_10_6_19_patch3" "CMSSW_10_6_17_patch1" "CMSSW_10_6_17_patch1" "CMSSW_9_4_14_UL_patch1" "CMSSW_10_6_17_patch1" "CMSSW_10_6_20")
elif [ "$campaign" == "RunIISummer20UL18" ]; then
    CMSSW=("CMSSW_10_6_19_patch3" "CMSSW_10_6_17_patch1" "CMSSW_10_6_17_patch1" "CMSSW_10_2_16_UL" "CMSSW_10_6_17_patch1" "CMSSW_10_6_20")
else
    echo "Wrong Campaign: $campaign"
    echo "You should select among RunIISummer20UL16 RunIISummer20UL16APV RunIISummer20UL17 RunIISummer20UL18"
    exit 1
fi
RUNS=("GEN" "SIM" "DIGIPremix" "HLT" "RECO" "MiniAODv2")

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc700

WD="/data6/Users/taehee/HerwigWD/hw7_validation/FullShower/HAHM/13TeV/SampleGeneration"
outputdir="\/gv0\/Users\/taehee\/HerwigSample"
mkdir -p /gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/${sample}
mkdir -p tmp/${campaign}/MZp-${zpmass}/${sample}

for ((i = 0; i < ${#RUNS[@]}; i++)); do
    output=${RUNS[$i]}
    if [ -s "/gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.root" ];then
        echo "/gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.root: File exists... pass"
        continue
    fi

    if [[ $output != "GEN" ]]; then
        input=${RUNS[$((i-1))]}
    fi
    cd /data9/Users/taehee/${CMSSW[$i]}/src
    eval `scram runtime -sh`
    scram b
    cd $WD
    sed -e "s/__OUTPUT__/${outputdir}\/samples\/${campaign}\/MZp-${zpmass}\/${sample}\/${output}_${process}/g" "files_cfg/${campaign}${output}_cfg.py" > "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
    if [[ $output == "GEN" ]]; then
        sed -i "s/__INPUT__/${outputdir}\/hw\/MZp-${zpmass}\/${sample}\/$process\/LHC/g" "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
        sed -i "s/__RANDOM__/${process}/g" "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
    else
        sed -i "s/__INPUT__/${outputdir}\/samples\/${campaign}\/MZp-${zpmass}\/${sample}\/${input}_${process}/g" "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
    fi
    cmsRun tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py &> tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.log

done
