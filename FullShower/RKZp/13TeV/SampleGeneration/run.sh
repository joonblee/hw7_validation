#!/bin/bash
# this script is for cms server

SAMPLES=("Pt-70To75_1777824" "Pt-75To80_1777825" "Pt-90To100_1777827" "Pt-100To120_1777828" "Pt-120To150_1777829" "Pt-150To9999_1777830" "Pt-65To67_1821387" "Pt-67To70_1821388" "Pt-70To75_1821389" "Pt-75To80_1821390" "Pt-80To85_1821391" "Pt-85To90_1821392" "Pt-90To100_1821393" "Pt-100To120_1821394" "Pt-120To150_1821395" "Pt-150To9999_1821396" "Pt-65To67_1889851" "Pt-67To70_1889952" "Pt-70To75_1890045" "Pt-75To80_1890046" "Pt-80To85_1890047" "Pt-85To90_1890048" "Pt-90To100_1890149" "Pt-100To120_1890150" "Pt-120To150_1890151" "Pt-150To9999_1890152")

SAMPLES=("Pt-100To110_2007186" "Pt-110To120_2007187" "Pt-90To95_2074823" "Pt-95To100_2074824" "Pt-100To110_2074825" "Pt-110To120_2074826" "Pt-120To130_2168785" "Pt-130To150_2168786" "Pt-150To200_2074828" "Pt-200To9999_2074829")
SAMPLES=("Pt-120To130_2168785" "Pt-130To150_2168786")
SAMPLES=("Pt-90To95_2213047" "Pt-100To110_2213049" "Pt-110To120_2213050")

SAMPLES=("Pt-100To110_2330633" "Pt-110To120_2330634")

campaign="RunIISummer20UL16"
zpmass=20
coupling="0p1"

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

WD="/data6/Users/taehee/Herwig/HerwigWD/hw7_validation/FullShower/RKZp/13TeV/SampleGeneration"
basedir_="\/data9\/Users\/taehee\/SampleProduction\/HerwigSample\/samples"
basedir="/data9/Users/taehee/SampleProduction/HerwigSample/samples"
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
        outputdir_="${campaign}\/MZp-${zpmass}\/gbb-${coupling}\/${sample}"
        outputdir="${campaign}/MZp-${zpmass}/gbb-${coupling}/${sample}"
        mkdir -p ${basedir}/${outputdir}
        mkdir -p tmp/${outputdir}
    
        NJOBS=$(ls -l /gv0/Users/taehee/HerwigSample/hw/MZp-${zpmass}/gbb-${coupling}/${sample} | grep '^d' | wc -l)
        for ((j = 0; j < $NJOBS; j++)); do
            process=${j}
            if [ -s "${basedir}/${outputdir}/${output}_${process}.root" ];then
                echo "${basedir}/${outputdir}/${output}_${process}.root: File exists... pass"
                continue
            elif [ -s "/gv0/Users/taehee/HerwigSample/samples/${campaign}/MZp-${zpmass}/gbb-${coupling}/${sample}/MiniAODv2_${process}.root" ]; then
                echo "${outputdir}/${output}_${process}.root: MiniAOD exists in gv0... pass"
                continue
            fi

            sed -e "s/__OUTPUT__/${basedir_}\/${outputdir_}\/${output}_${process}/g" "files_cfg/${campaign}${output}_cfg.py" > "tmp/${outputdir}/${output}_${process}.py"
            if [[ $output == "GEN" ]]; then
                if [ ! -f "/gv0/Users/taehee/HerwigSample/hw/MZp-${zpmass}/gbb-${coupling}/${sample}/${process}/filtered.hepmc" ];then
                    echo "${outputdir}/${output}_${j}: filtered.hepmc does not exist... pass"
                    continue
                fi
                sed -i "s/__INPUT__/\/gv0\/Users\/taehee\/HerwigSample\/hw\/MZp-${zpmass}\/gbb-${coupling}\/${sample}\/${process}\/filtered/g" "tmp/${outputdir}/${output}_${process}.py"
                sed -i "s/__RANDOM__/${process}/g" "tmp/${outputdir}/${output}_${process}.py"
            else
                if [ ! -f "${basedir}/${outputdir}/${input}_${process}.root" ]; then
                    echo "${outputdir}/${output}_${j}: no input files... pass"
                    continue
                fi
                sed -i "s/__INPUT__/${basedir_}\/${outputdir_}\/${input}_${process}/g" "tmp/${outputdir}/${output}_${process}.py"
            fi
            cmsRun tmp/${outputdir}/${output}_${process}.py &> tmp/${outputdir}/${output}_${process}.log &

            echo "Running ${outputdir}/${output}_${j}..."
            nJobs=`ps aux | grep -v "grep" | grep "taehee" | grep -c "cmsRun"`
            while [ $nJobs -ge 65 ]; do
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

for ((k = 0; k < ${#SAMPLES[@]}; k++)); do
    sample=${SAMPLES[k]}
    outputdir="${campaign}/MZp-${zpmass}/gbb-${coupling}/${sample}"
    mkdir -p /gv0/Users/taehee/HerwigSample/samples/${outputdir}
    echo "Moving MiniAOD files from data9 to gv0: ${outputdir}"
    mv ${basedir}/${outputdir}/MiniAODv2_*root /gv0/Users/taehee/HerwigSample/samples/${outputdir}/
done
