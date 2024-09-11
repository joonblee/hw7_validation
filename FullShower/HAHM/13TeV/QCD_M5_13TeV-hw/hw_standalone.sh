#!/bin/bash

#############
### setup ###
#############

Ncore=4

CompileUFO=true
UFOName=HAHM_variableMW_v3_UFO
CompileRivet=true
makehtml=true

runLHC=true
NRUN_LHC=1
EVTpRUN_LHC=1000

this_dir=$PWD

###########
### run ###
###########

echo ""
now=$(date +"%T")
echo "Starting time : $now"
echo ""
echo ""

Hw_Loc=/data6/Users/joonblee/hw_singularity
RB="$Hw_Loc/bin/rivet-build"
source "$Hw_Loc/bin/activate"

# compiling ufo file
if $CompileUFO; then
  rm -rf *FR* Makefile __pycache__
  rm -rf ${UFOName}
  if [[ ! -d ${UFOName} ]]; then
    echo "${UFOName} folder does not exist."
    echo "Check if ${UFOName} exists..."
    if [[ ! -f "${UFOName}.tar.gz" ]]; then
      echo "${UFOName} does not exist."
      echo "Install from the cms web."
      wget https://cms-project-generators.web.cern.ch/cms-project-generators/HAHM_variableMW_v3_UFO.tar.gz
    fi
    echo "Untar the tar ball."
    tar -zxvf HAHM_variableMW_v3_UFO.tar.gz
    sed -i "39s/20/5./" ${UFOName}/parameters.py
  fi
  ufo2herwig ${UFOName} --enable-bsm-shower --convert
  sed -i "s/echo \*.cc/echo FRModel*.cc/g" Makefile
  sed -i "36,44s/^/#/" FRModel.model
  sed -i "66,74s/^/#/" FRModel.model
  sed -i "86,94s/^/#/" FRModel.model
  sed -i "106,114s/^/#/" FRModel.model
  #sed -i "176,272s/^/#/" FRModel.model
  make
fi

# compiling rivet analysis
if $CompileRivet; then
  echo "Compile the rivet analysis, RAnalysis.cc"
  $RB Rivet.so RAnalysis.cc
  export RIVET_ANALYSIS_PATH=$PWD
  echo ""
fi

if $runLHC; then
  for ((i=1; i<=${NRUN_LHC}; i++))
  do
    echo "Start runnning LHC-${i}"
    rnum=$(shuf -i 1-99999999 -n 1)

    sed -e "s/__NEVENTS__/${EVTpRUN_LHC}/g" ${this_dir}/LHC.in > ${this_dir}/LHC-${i}.in
    sed -i "s/__SEED__/${rnum}/g"                              ${this_dir}/LHC-${i}.in
    sed -i "s/__RUN__/${i}/g"                                  ${this_dir}/LHC-${i}.in
    Herwig read LHC-${i}.in
    Herwig run LHC-${i}.run &> LHC-${i}run.log &

    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    while (( $nJobs >= $Ncore ))
    do
      sleep 100
      nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    done
  done
fi

nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
while [[ $nJobs != 0 ]]
do
  sleep 60
  nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
done

# run rivet
if $makehtml; then
  echo "#########################"
  echo "# ----- Run rivet ----- #"
  echo "#########################"
  yodamerge -o LHC.yoda LHC-*.yoda
  rivet-mkhtml LHC.yoda
fi

deactivate

# Clear directory
echo ""
now=$(date +"%T")
echo "End time : $now"

echo ""
echo "done"
echo ""
