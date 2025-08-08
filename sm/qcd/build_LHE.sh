#!/bin/bash

#############
### setup ###
#############
rm -rf QCD-EvtGen.log QCD-run.log QCD.out QCD.run QCD.tex rivet-plots

Hw_Loc=/data6/Users/joonblee/hw_singularity #home/joonblee/WD/herwig74test
MG_version="MG5_aMC_v3_5_1"

Ncore=72
NRUN=1000

nevents=10000
ebeam=6500

MG="$Hw_Loc/opt/$MG_version/bin/mg5_aMC"

# setup file to be stored
for ((i=101; i<=${NRUN}; i++))
do

  nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep -c "MG"`
  while (( $nJobs >= $Ncore ))
  do
    sleep 30 
    nJobs=`ps aux | grep -v "grep" | grep "joonblee" | grep -c "MG"`
  done
      
  echo "Start runnning QCD-${i}"

  WD=$PWD
  DIR=QCD-$i
  mkdir $DIR
  cd $DIR

  QCD_File="MG_setup-${i}.dat"
  if [ -d "$DIR" ]; then
    echo "$DIR exists, erase"
    rm -rf $DIR
  fi
  echo "set auto_update 0"                     >> $QCD_File
  echo "import model sm-no_b_mass"             >> $QCD_File
  echo "define p = g u c d s u~ c~ d~ s~ b b~" >> $QCD_File
  echo "define j = g u c d s u~ c~ d~ s~ b b~" >> $QCD_File
  echo "define bb = b b~"                      >> $QCD_File
  echo "generate p p > bb j @0"                >> $QCD_File
  #echo "add process p p > bb j j @1"            >> $QCD_File # Matching should be set for higher multiplicity 
  #echo "add process p p > bb j j j @2"          >> $QCD_File
  echo "output madevent $DIR"                  >> $QCD_File
  echo "launch"                                >> $QCD_File
  echo "set nevents $nevents"                  >> $QCD_File
  echo "set ebeam1 $ebeam"                     >> $QCD_File
  echo "set ebeam2 $ebeam"                     >> $QCD_File
  echo "set etaj 5."                           >> $QCD_File
  echo "set etab 5."                           >> $QCD_File
  echo "set ptj 20."                           >> $QCD_File
  echo "set ptb 20."                           >> $QCD_File
  echo "set drjj 0.4"                          >> $QCD_File
  echo "set drbj 0.4"                          >> $QCD_File
  echo "set drbb 0.4"                          >> $QCD_File
  echo "set maxjetflavor 5"                    >> $QCD_File
  echo "set systematics_program none"          >> $QCD_File
  echo "set systematics_arguments []"          >> $QCD_File
  $MG $QCD_File &> ${DIR}.log &
  sleep 1
  cd $WD
done

rm py.py MG_setup.dat MG5_debug 

