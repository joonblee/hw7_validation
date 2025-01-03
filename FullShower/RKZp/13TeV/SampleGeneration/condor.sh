#!/bin/bash

process=${1}
sample=${2}
campaign=${3}
zpmass=${4}
coupling=${5}

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

WD="/data6/Users/taehee/Herwig/HerwigWD/hw7_validation/FullShower/RKZp/13TeV/SampleGeneration"
cd $WD
basedir_="\/data9\/Users\/taehee\/SampleProduction\/HerwigSample\/samples"
basedir="/data9/Users/taehee/SampleProduction/HerwigSample/samples"
outputdir_="${campaign}\/MZp-${zpmass}\/gbb-${coupling}\/${sample}"
outputdir="${campaign}/MZp-${zpmass}/gbb-${coupling}/${sample}"
mkdir -p ${basedir}/${outputdir}
mkdir -p tmp/${outputdir}

for ((i = 0; i < ${#RUNS[@]}; i++)); do
    output=${RUNS[$i]}
    if [[ $output != "GEN" ]]; then
        input=${RUNS[$((i-1))]}
    fi

    if [ -s "/gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/gbb-${coupling}/${sample}/MiniAODv2_${process}.root" ]; then
        echo /gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/gbb-${coupling}/${sample}/MiniAODv2_${process}.root exists... exit
        exit 1
    fi
    if [ -s "${basedir}/${outputdir}/${output}_${process}.root" ];then
        echo "${basedir}/${outputdir}/${output}_${process}.root: File exists... pass"
        continue
    fi

    sed -e "s/__OUTPUT__/${basedir_}\/${outputdir_}\/${output}_${process}/g" "files_cfg/${campaign}${output}_cfg.py" > "tmp/${outputdir}/${output}_${process}.py"
    if [[ $output == "GEN" ]]; then
        if [ ! -f "/gv0/Users/taehee/HerwigSample/hw/MZp-${zpmass}/gbb-${coupling}/${sample}/${process}/filtered.hepmc" ];then
            echo "${outputdir}/${output}_${process}: filtered.hepmc does not exist... exit"
            exit 1
        fi
        sed -i "s/__INPUT__/\/gv0\/Users\/taehee\/HerwigSample\/hw\/MZp-${zpmass}\/gbb-${coupling}\/${sample}\/${process}\/filtered/g" "tmp/${outputdir}/${output}_${process}.py"
        sed -i "s/__RANDOM__/${process}/g" "tmp/${outputdir}/${output}_${process}.py"
    else
        if [ ! -f "${basedir}/${outputdir}/${input}_${process}.root" ]; then
            echo "${outputdir}/${output}_${process}: no input files... exit"
            exit
        fi
        sed -i "s/__INPUT__/${basedir_}\/${outputdir_}\/${input}_${process}/g" "tmp/${outputdir}/${output}_${process}.py"
    fi

    cd /data9/Users/taehee/${CMSSW[$i]}/src
    eval `scram runtime -sh`
    scram b
    cd $WD

    cmsRun tmp/${outputdir}/${output}_${process}.py &> tmp/${outputdir}/${output}_${process}.log
    echo "Running ${outputdir}/${output}_${process}..."

done

mkdir -p /gv0/Users/taehee/HerwigSample/samples/${outputdir}
echo "Moving MiniAOD files from data9 to gv0: ${outputdir}"
mv ${basedir}/${outputdir}/MiniAODv2_${process}.root /gv0/Users/taehee/HerwigSample/samples/${outputdir}/
