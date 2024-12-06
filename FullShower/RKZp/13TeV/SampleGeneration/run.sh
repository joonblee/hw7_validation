#!/bin/bash
# this script is for cms server

SAMPLES=("Pt-65To70_1366783" "Pt-70To75_1366784" "Pt-75To80_1366785" "Pt-80To85_1366786" "Pt-85To90_1366787" "Pt-90To100_1366788" "Pt-100To140_1366789" "Pt-140To200_1366790" "Pt-200To9999_1366792")
campaign="RunIISummer20UL18"
zpmass=5

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

voms-proxy-init --voms cms -valid 192:00
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc700

WD="/data6/Users/taehee/HerwigWD/hw7_validation/FullShower/HAHM/13TeV/SampleGeneration"
for ((i = 0; i < ${#RUNS[@]}; i++)); do
    output=${RUNS[$i]}
    if [[ $output != "GEN" ]]; then
        input=${RUNS[$((i-1))]}
    fi
    cd /data9/Users/taehee/${CMSSW[$i]}/src
    eval `scram runtime -sh`
    scram b
    cd $WD

    for ((k = 0; k < ${#SAMPLES[@]}; k++)); do
        sample=${SAMPLES[k]}
        outputdir="\/gv0\/Users\/taehee\/HerwigSample"
        mkdir -p /gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/${sample}
        mkdir -p tmp/${campaign}/MZp-${zpmass}/${sample}
    
        NJOBS=$(ls -l /gv0/Users/taehee/HerwigSample/hw/MZp-${zpmass}/${sample} | grep '^d' | wc -l)
        for ((j = 0; j < $NJOBS; j++)); do
            process=${j}
            if [ -s "/gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.root" ];then
                echo "/gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.root: File exists... pass"
                continue
            fi

            sed -e "s/__OUTPUT__/${outputdir}\/samples\/${campaign}\/MZp-${zpmass}\/${sample}\/${output}_${process}/g" "files_cfg/${campaign}${output}_cfg.py" > "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
            if [[ $output == "GEN" ]]; then
                sed -i "s/__INPUT__/${outputdir}\/hw\/MZp-${zpmass}\/${sample}\/$process\/LHC/g" "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
                sed -i "s/__RANDOM__/${process}/g" "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
            else
                sed -i "s/__INPUT__/${outputdir}\/samples\/${campaign}\/MZp-${zpmass}\/${sample}\/${input}_${process}/g" "tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py"
            fi
            cmsRun tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.py &> tmp/${campaign}/MZp-${zpmass}/${sample}/${output}_${process}.log &

            echo "Running ${campaign}/MZp-${zpmass}/${sample}/${output}_${j}..."
            nJobs=`ps aux | grep -v "grep" | grep "taehee" | grep -c "cmsRun"`
            while [ $nJobs -ge 60 ]; do
                sleep 60
                nJobs=`ps aux | grep -v "grep" | grep "taehee" | grep -c "cmsRun"`
            done
        done
    done

    nJobs=`ps aux | grep -v "grep" | grep "taehee" | grep -c "cmsRun"`
    while [ $nJobs -ge 1 ]; do
        sleep 60
        nJobs=`ps aux | grep -v "grep" | grep "taehee" | grep -c "cmsRun"`
    done

done

