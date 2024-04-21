#!/bin/bash

#############
### setup ###
#############

Ncore=4

CompileUFO=false
UFOName=2HDM
CompileRivet=true
makehtml=true

NRUN=4
EVTpRUN=100000

this_dir=$PWD

rm -rf rivet-plots tmp

###########
### run ###
###########

echo ""
now=$(date +"%T")
echo "Starting time : $now"
echo ""
echo ""

Hw_Loc=/home/joonblee/WD/herwigtest3
RB="$Hw_Loc/bin/rivet-build"
source "$Hw_Loc/bin/activate"

# compiling ufo file
if $CompileUFO; then
  rm -rf *FR* Makefile __pycache__
  rm -rf ${UFOName}
  if [[ ! -d ${UFOName} ]]; then
    echo "${UFOName} folder does not exist."
    echo "Check if ${UFOName}_UFO.tar.gz exists..."
    if [[ ! -f "${UFOName}_UFO.tar.gz" ]]; then
      echo "${UFOName}_UFO.tar.gz does not exist."
      echo "Install from the Feynrules web."
      wget https://feynrules.irmp.ucl.ac.be/raw-attachment/wiki/2HDM/2HDM_UFO.tar.gz
    fi  
    echo "Untar the tar ball."
    tar xvf ${UFOName}_UFO.tar.gz
    sed -i "s/120/125/" 2HDM/parameters.py
    sed -i "s/130/10/" 2HDM/parameters.py
    sed -i "s/140/10/" 2HDM/parameters.py
    sed -i "s/150/10/" 2HDM/parameters.py
  fi
  ufo2herwig ${UFOName} --convert --enable-bsm-shower
  sed -i "s/echo \*.cc/echo FRModel*.cc/g" Makefile
  make
fi

# compiling rivet analysis
if $CompileRivet; then
  echo ""
  echo "Compile the rivet analysis, Find.cc"
  $RB Rivet.so Find.cc
  export RIVET_ANALYSIS_PATH=$PWD
  echo ""
fi


# run herwig
if ((${NRUN} > 0)); then
  echo "Start sample production"
  for ((i=1; i<=${NRUN}; i++))
  do
    echo ""
    echo "Start runnning LHC-${i}"
    rnum=$(shuf -i 1-99999999 -n 1)
    
    sed -e "s/__NEVENTS__/${EVTpRUN}/g" ${this_dir}/LHC.in > ${this_dir}/LHC-${i}.in
    sed -i "s/__SEED__/${rnum}/g"                            ${this_dir}/LHC-${i}.in
    sed -i "s/__RUN__/${i}/g"                                ${this_dir}/LHC-${i}.in
    Herwig read LHC-${i}.in
    Herwig run LHC-${i}.run &> LHC-${i}run.log &
  
    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    while (( $nJobs >= $Ncore ))
    do
      sleep 300
      nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    done
  done
  
  while [[ $nJobs != 0 ]]
  do
    sleep 60
    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
  done
fi

# run rivet
if $makehtml; then
  echo ""
  echo ""
  echo "#########################"
  echo "# ----- Run rivet ----- #"
  echo "#########################"
  rm LHC.yoda
  yodamerge -o LHC.yoda LHC-*.yoda
  rivet-mkhtml LHC.yoda
fi

deactivate

# Clear directory
mkdir tmp
#rm *.run *run.log *.tex *-EvtGen.log *-*.in
echo ""
now=$(date +"%T")
echo "End time : $now"


echo ""
echo "done"
echo ""
