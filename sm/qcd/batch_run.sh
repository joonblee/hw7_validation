#!/bin/bash

#############
### setup ###
#############

Ncore=72

CompileRivet=true
makehtml=false

NRUN=1000
EVTpRUN=10000

this_dir=$PWD

#rm -rf QCD-EvtGen.log QCD-run.log QCD.log QCD.out QCD.run QCD.tex QCD.yoda rivet-plots 
rm -rf rivet-plots tmp

###########
### run ###
###########

echo ""
now=$(date +"%T")
echo "Starting time : $now"
echo ""
echo ""

Hw_Loc=/data6/Users/joonblee/hw_singularity/
RB="$Hw_Loc/bin/rivet-build"
source "$Hw_Loc/bin/activate"

# compiling rivet analysis
if $CompileRivet; then
  echo "Compile the rivet analysis, RAnalysis.cc"
  $RB Rivet.so RAnalysis.cc
  export RIVET_ANALYSIS_PATH=$PWD
  echo ""
fi

# run herwig
for ((i=101; i<=${NRUN}; i++))
do
  echo "Start runnning QCD-${i}"
  cd ${this_dir}/QCD-$i

  rnum=$(shuf -i 1-99999999 -n 1)

  sed -e "s/__NEVENTS__/${EVTpRUN}/g" ${this_dir}/QCD.in > ${this_dir}/QCD-${i}/QCD.in
  sed -i "s/__SEED__/${rnum}/g"                              ${this_dir}/QCD-${i}/QCD.in
  sed -i "s/__RUN__/${i}/g"                                  ${this_dir}/QCD-${i}/QCD.in
  Herwig read QCD.in
  Herwig run QCD.run &> QCD-run.log &

  nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
  while (( $nJobs >= $Ncore ))
  do
    sleep 300
    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
  done
  cd ${this_dir}
done

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
  rm QCD.yoda
  yodamerge -o QCD.yoda ${this_dir}/QCD-${i}/QCD.yoda
  rivet-mkhtml QCD.yoda;
fi
 
deactivate

# Clear directory
#mkdir tmp
#mv QCD-1.log tmp/QCD.log; mv QCD-1.out tmp/QCD.out; mv QCD-1run.log tmp/QCD-run.log
#rm *.run *run.log *.tex *-EvtGen.log *-*.in
echo ""
now=$(date +"%T")
echo "End time : $now"

echo ""
echo "done"
echo ""
