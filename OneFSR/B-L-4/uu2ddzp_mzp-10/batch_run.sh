#!/bin/bash

#############
### setup ###
#############

Ncore=4

CompileRivet=true
CompileUFO=true
UFOName=B-L-4_UFO
makehtml=true

runFO=true
NRUN_FO=1
EVTpRUN_FO=1000000

runRS=true
NRUN_RS=7
EVTpRUN_RS=1000000

runFO_veto_radiation=false
runFO_only_radiation=false
NRUN=0
EVTpRUN=200000

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
  rm -rf ${UFOName} *FR* Makefile __pycache__ __MACOSX
  if [[ ! -f "${UFOName}.zip"  ]]; then
    wget https://feynrules.irmp.ucl.ac.be/raw-attachment/wiki/B-L-SM/B-L-4_UFO.zip
  fi
  unzip ${UFOName}.zip
  sed -i "s/1500/10/g" ${UFOName}/parameters.py
  sed -i "s/80\./0.01/g" ${UFOName}/parameters.py
  ufo2herwig ${UFOName} --convert
  sed -i "s/echo \*.cc/echo FRModel*.cc/g" Makefile
  make
  # It looks Herwig does not have the phi0p particle. Comment out related lines
  #sed -i "166,184 s/^/#/" FRModel.model
  #sed -i "236,254 s/^/#/" FRModel.model
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

if $runFO_veto_radiation; then
  for ((i=1; i<=${NRUN}; i++))
  do
    echo "Start runnning FO-veto_radiation-${i}"
    rnum=$(shuf -i 1-99999999 -n 1)
    
    sed -e "s/__NEVENTS__/${EVTpRUN}/g" ${this_dir}/FO.in > ${this_dir}/FO-veto_radiation-${i}.in
    sed -i "s/__SEED__/${rnum}/g"                           ${this_dir}/FO-veto_radiation-${i}.in
    sed -i "s/__RUN__/${i}/g"                               ${this_dir}/FO-veto_radiation-${i}.in
    sed -i "s/FO/FO-veto_radiation/g"                       ${this_dir}/FO-veto_radiation-${i}.in
    Herwig read FO-veto_radiation-${i}.in
    Herwig run FO-veto_radiation-${i}.run &> FO-veto_radiation-${i}run.log &

    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    while (( $nJobs >= $Ncore ))
    do
      sleep 300
      nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    done
  done
  #rm FO-veto_radiation-*.in FO-veto_radiation-*.run
fi

if $runFO_only_radiation; then
  for ((i=1; i<=${NRUN}; i++))
  do
    echo "Start runnning FO-only_radiation-${i}"
    rnum=$(shuf -i 1-99999999 -n 1)
    
    sed -e "s/__NEVENTS__/${EVTpRUN}/g" ${this_dir}/FO.in > ${this_dir}/FO-only_radiation-${i}.in
    sed -i "s/__SEED__/${rnum}/g"                           ${this_dir}/FO-only_radiation-${i}.in
    sed -i "s/__RUN__/${i}/g"                               ${this_dir}/FO-only_radiation-${i}.in
    sed -i "s/FO/FO-only_radiation/g"                       ${this_dir}/FO-only_radiation-${i}.in
    Herwig read FO-only_radiation-${i}.in
    Herwig run FO-only_radiation-${i}.run &> FO-only_radiation-${i}run.log &

    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    while (( $nJobs >= $Ncore ))
    do
      sleep 300 
      nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep "run" | grep -c "Herwig"`
    done
  done
  #rm FO-only_radiation-*.in FO-only_radiation-*.run
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
  if ( $runFO && ! $runRS ); then rivet-mkhtml FO.yoda; fi
  if ( ! $runFO && $runRS ); then rivet-mkhtml RS.yoda; fi
  if ( $runFO && $runRS ); then rivet-mkhtml FO.yoda:'Title=FO' RS.yoda:'Title=RS:Scale=0.01'; fi
  #if ( $runFO && $runRS ); then rivet-mkhtml FO.yoda:'Title=FO' FO-veto_radiation-1.yoda:'Title=FO(veto rad)' FO-only_radiation-1.yoda:'Title=FO(radiation)'  RS.yoda:'Title=RS'; fi
fi
 
deactivate

# Clear directory
#mkdir tmp
#mv FO-1.log tmp/FO.log; mv FO-1.out tmp/FO.out; mv FO-1run.log tmp/FO-run.log
#mv FO-veto_radiation-1.log tmp/FO-veto_radiation.log; mv FO-veto_radiation-1.out tmp/FO-veto_radiation.out; mv FO-veto_radiation-1run.log tmp/FO-veto_radiation-run.log
#mv FO-only_radiation-1.log tmp/FO-only_radiation.log; mv FO-only_radiation-1.out tmp/FO-only_radiation.out; mv FO-only_radiation-1run.log tmp/FO-only_radiation-run.log
#mv RS-1.log tmp/RS.log; mv RS-1.out tmp/RS.out; mv RS-1run.log tmp/RS-run.log
#rm *.run *run.log *.tex *-EvtGen.log *-*.in
echo ""
now=$(date +"%T")
echo "End time : $now"

echo ""
echo "done"
echo ""
