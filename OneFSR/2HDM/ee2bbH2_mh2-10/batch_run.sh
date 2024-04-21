#!/bin/bash

#############
### setup ###
#############

Ncore=4

CompileUFO=true
UFOName=2HDM
CompileRivet=true
makehtml=true

runFO=true
NRUN_FO=1
EVTpRUN_FO=1000000

runDF=false
NRUN_DF=1
EVTpRUN_DF=100000

runRS=true
NRUN_RS=100
EVTpRUN_RS=1000000

this_dir=$PWD

#rm -rf FO-EvtGen.log FO-run.log FO.log FO.out FO.run FO.tex FO.yoda RS-EvtGen.log RS-run.log RS.log RS.out RS.run RS.tex RS.yoda rivet-plots 
rm -rf rivet-plots tmp

###########
### run ###
###########

echo ""
now=$(date +"%T")
echo "Starting time : $now"
echo ""
echo ""

Hw_Loc=/home/joonblee/WD/Herwig
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
    sed -i "s/130/10/" 2HDM/parameters.py
  fi
  ufo2herwig ${UFOName} --convert
  sed -i "s/echo \*.cc/echo FRModel*.cc/g" Makefile
  make
fi

# compiling rivet analysis
if $CompileRivet; then
  echo "Compile the rivet analysis, RAnalysis.cc"
  $RB Rivet.so RAnalysis.cc
  export RIVET_ANALYSIS_PATH=$PWD
  echo ""
fi

# run herwig
if $runFO; then
  for ((i=1; i<=${NRUN_FO}; i++))
  do
    echo "Start runnning FO-${i}"
    rnum=$(shuf -i 1-99999999 -n 1)
    
    sed -e "s/__NEVENTS__/${EVTpRUN_FO}/g" ${this_dir}/FO.in > ${this_dir}/FO-${i}.in
    sed -i "s/__SEED__/${rnum}/g"                              ${this_dir}/FO-${i}.in
    sed -i "s/__RUN__/${i}/g"                                  ${this_dir}/FO-${i}.in
    Herwig read FO-${i}.in
    Herwig run FO-${i}.run &> FO-${i}run.log &

    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    while (( $nJobs >= $Ncore ))
    do
      sleep 300
      nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    done
  done
fi

if $runDF; then
  for ((i=1; i<=${NRUN_DF}; i++))
  do
    echo "Start runnning DF-${i}"
    rnum=$(shuf -i 1-99999999 -n 1)
    
    sed -e "s/__NEVENTS__/${EVTpRUN_DF}/g" ${this_dir}/FO.in > ${this_dir}/DF-${i}.in
    sed -i "s/__SEED__/${rnum}/g"                              ${this_dir}/DF-${i}.in
    sed -i "s/__RUN__/${i}/g"                                  ${this_dir}/DF-${i}.in
    sed -i "s/FO/DF/g"                                         ${this_dir}/DF-${i}.in
    Herwig read DF-${i}.in
    Herwig run DF-${i}.run &> DF-${i}run.log &

    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    while (( $nJobs >= $Ncore ))
    do
      sleep 300
      nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    done
    rm DF-${i}.in Df-${i}.run
  done
fi

if $runRS; then
  for ((i=1; i<=${NRUN_RS}; i++))
  do
    echo "Start runnning RS-${i}"
    rnum=$(shuf -i 1-99999999 -n 1)

    sed -e "s/__NEVENTS__/${EVTpRUN_RS}/g" ${this_dir}/RS.in > ${this_dir}/RS-${i}.in
    sed -i "s/__SEED__/${rnum}/g"                              ${this_dir}/RS-${i}.in
    sed -i "s/__RUN__/${i}/g"                                  ${this_dir}/RS-${i}.in
    Herwig read RS-${i}.in
    Herwig run RS-${i}.run &> RS-${i}run.log &

    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    while (( $nJobs >= $Ncore ))
    do
      sleep 300
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
  rm FO.yoda RS.yoda
  yodamerge -o FO.yoda FO-[123456789]*.yoda
  yodamerge -o RS.yoda RS-*.yoda
  sed -i "s/_RS//g" RS-1.yoda
  sed -i "s/_FO//g" FO-1.yoda
  if ( $runFO && ! $runRS ); then rivet-mkhtml FO.yoda; fi
  if ( ! $runFO && $runRS ); then rivet-mkhtml RS.yoda; fi
  if ( $runFO && $runRS ); then rivet-mkhtml FO.yoda:'Title=FO' RS.yoda:'Title=RS'; fi
fi

deactivate

# Clear directory
mkdir tmp
mv FO-1.log tmp/FO.log; mv FO-1.out tmp/FO.out; mv FO-1run.log tmp/FO-run.log
mv RS-1.log tmp/RS.log; mv RS-1.out tmp/RS.out; mv RS-1run.log tmp/RS-run.log
rm *.run *run.log *.tex *-EvtGen.log *-*.in
echo ""
now=$(date +"%T")
echo "End time : $now"

echo ""
echo "done"
echo ""
