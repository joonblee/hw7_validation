#!/bin/bash

#############
### setup ###
#############
runRS=true
runFO=true

NRUN_FO=10
NRUN_RS=10

rm -rf FO*-EvtGen.log FO*-run*.log FO*.out FO*.run FO*.tex RS-EvtGen.log RS-run.log RS.out RS.run RS.tex rivet-plots

Hw_Loc=/home/joonblee/WD/Herwig
MG_version="MG5_aMC_v3_3_2"

nevents=1000000
ebeam=500

MG="$Hw_Loc/opt/$MG_version/bin/mg5_aMC"

# setup file for RS to be stored
if $runRS; then
  RS_File="MG_setup_RS.dat"
  for ((i=2; i<=${NRUN_RS}; i++))
  do
    RS_DIR="RS$i"
    echo "Run " $RS_DIR
    if [ -d "$RS_DIR" ]; then
      echo "$RS_DIR exists, erase"
      rm -rf $RS_DIR
    fi
    echo "set auto_update 0"                     >> $RS_File
    echo "import model 2HDM"                     >> $RS_File
    echo "generate e+ e- > b b~"                 >> $RS_File
    echo "output madevent $RS_DIR"               >> $RS_File
    echo "launch"                                >> $RS_File
    echo "set nevents $nevents"                  >> $RS_File
    echo "set ebeam1 $ebeam"                     >> $RS_File
    echo "set ebeam2 $ebeam"                     >> $RS_File
    echo "set mass 25 125"                       >> $RS_File
    echo "set mass 35 130"                        >> $RS_File
    echo "set width 35 0.01"                     >> $RS_File
    echo "set systematics_program none"          >> $RS_File
    echo "set systematics_arguments []"          >> $RS_File
    $MG $RS_File 
  done
fi

# setup file for FO to be stored
if $runFO;then
  FO_File="MG_setup_FO.dat"
  for ((i=2; i<=${NRUN_FO}; i++))
  do
    FO_DIR="FO$i"
    echo "Run " $FO_DIR
    if [ -d "$FO_DIR" ]; then
      echo "$FO_DIR exists, erase"
      rm -rf $FO_DIR
    fi
    echo "set auto_update 0"                     >> $FO_File
    echo "import model 2HDM"                     >> $FO_File
    echo "generate e+ e- > b | b~ > b b~ h2"     >> $FO_File
    echo "output madevent $FO_DIR"               >> $FO_File
    echo "launch"                                >> $FO_File
    echo "set nevents $nevents"                  >> $FO_File
    echo "set ebeam1 $ebeam"                     >> $FO_File
    echo "set ebeam2 $ebeam"                     >> $FO_File
    echo "set etab 5."                           >> $FO_File
    echo "set mass 25 125"                       >> $FO_File
    echo "set mass 35 130"                        >> $FO_File
    echo "set width 35 0.01"                     >> $FO_File
    echo "set systematics_program none"          >> $FO_File
    echo "set systematics_arguments []"          >> $FO_File
    $MG $FO_File 
  done
fi

rm py.py MG_setup_FO.dat MG_setup_RS.dat MG5_debug 

