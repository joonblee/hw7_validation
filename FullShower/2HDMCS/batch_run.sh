#!/bin/bash

#############
### setup ###
#############

Ncore=4

CompileUFO=true
UFOName=pSDM+2HDM-LO-UFO-Final
CompileRivet=true
makehtml=true

NRUN=4
EVTpRUN=10000

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

Hw_Loc=/home/joonblee/WD/herwigtest3
RB="$Hw_Loc/bin/rivet-build"
source "$Hw_Loc/bin/activate"

# compiling ufo file
if $CompileUFO; then
  echo ""
  echo "Erase the current ${UFOName} folder"
  rm -rf *FR* Makefile __pycache__
  rm -rf ${UFOName}
  cp ../${UFOName}.zip ./
  echo "Unzip the ${UFOName}.zip"
  unzip ${UFOName}
  mv UFO pSDM+2HDM-LO-UFO-Final
  sed -i "1553s/complex/real/g" ${UFOName}/parameters.py

  sed -i "27,41s/1.270000/1.199/g" ${UFOName}/parameters.py
  sed -i "62s/1.44/1.685/g" ${UFOName}/parameters.py
  sed -i "70s/1.45/1.011/g" ${UFOName}/parameters.py
  sed -i "78s/1.41/1.285/g" ${UFOName}/parameters.py
  sed -i "86s/-0.3/0.49/g" ${UFOName}/parameters.py
  sed -i "94s/-0.4/-1.99/g" ${UFOName}/parameters.py
  sed -i "102s/-0.3/-0.49/g" ${UFOName}/parameters.py
  sed -i "118s/3600/120962.753209/g" ${UFOName}/parameters.py
  sed -i "126s/225/62500/g" ${UFOName}/parameters.py
  sed -i "718s/730/443.173/g" ${UFOName}/parameters.py
  sed -i "806s/125.24/125.25/g" ${UFOName}/parameters.py
  sed -i "814s/310/210.08/g" ${UFOName}/parameters.py
  sed -i "822s/340/347.76/g" ${UFOName}/parameters.py
  sed -i "830s/400/386.18/g" ${UFOName}/parameters.py
  sed -i "838s/500/529.16/g" ${UFOName}/parameters.py
  sed -i "846s/30/500/g" ${UFOName}/parameters.py

  echo ""
  echo " ++ Run ufo2herwig ++"
  ufo2herwig ${UFOName} --enable-bsm-shower --convert
  sed -i "s/echo \*.cc/echo FRModel*.cc/g" Makefile
  echo ""
  echo " ++ make ++"
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
