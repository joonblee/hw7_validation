#!/bin/bash

#############
### setup ###
#############
runRS=true
runFO=true

rm -rf FO*-EvtGen.log FO*-run*.log FO*.out FO*.run FO*.tex RS-EvtGen.log RS-run.log RS.out RS.run RS.tex rivet-plots

Hw_Loc=[YOUR_HW_DIRECTORY]
MG_version="MG5_aMC_v[YOUR_MG_VERSION]"

nevents=1000
ebeam=6800

MG="$Hw_Loc/opt/$MG_version/bin/mg5_aMC"

# setup file for RS to be stored
if $runRS; then
  RS_File="MG_setup_RS.dat"
  RS_DIR=RS
  if [ -d "$RS_DIR" ]; then
    echo "$RS_DIR exists, erase"
    rm -rf $RS_DIR
  fi
  echo "set auto_update 0"                     >> $RS_File
  echo "import model B-L-4_UFO"                >> $RS_File
  echo "generate u u~ > d d~"                  >> $RS_File
  echo "output madevent $RS_DIR"               >> $RS_File
  echo "launch"                                >> $RS_File
  echo "set nevents $nevents"                  >> $RS_File
  echo "set ebeam1 $ebeam"                     >> $RS_File
  echo "set ebeam2 $ebeam"                     >> $RS_File
  echo "set etaj 3."                           >> $RS_File
  echo "set ptj 20."                           >> $RS_File
  echo "set drjj 0.4"                          >> $RS_File
  echo "set mass 9900032 10"                   >> $RS_File
  echo "set mass 25 125"                       >> $RS_File
  echo "set width 9900032 0.01"                >> $RS_File
  echo "set systematics_program none"          >> $RS_File
  echo "set systematics_arguments []"          >> $RS_File
  $MG $RS_File 
fi

# setup file for FO to be stored
if $runFO;then
  FO_File="MG_setup_FO.dat"
  FO_DIR=FO
  cp MG_filter/user_filter.py ${Hw_Loc}/opt/MG5_aMC_v3_3_2/PLUGIN/user_filter.py
  if [ -d "$FO_DIR" ]; then
    echo "$FO_DIR exists, erase"
    rm -rf $FO_DIR
  fi
  echo "set auto_update 0"                        >> $FO_File
  echo "import model B-L-4_UFO"                   >> $FO_File
  echo "generate u u~ > d d~ zp --diagram_filter" >> $FO_File
  echo "output madevent $FO_DIR"                  >> $FO_File
  echo "launch"                                   >> $FO_File
  echo "set nevents $nevents"                     >> $FO_File
  echo "set ebeam1 $ebeam"                        >> $FO_File
  echo "set ebeam2 $ebeam"                        >> $FO_File
  echo "set etaj 5."                              >> $FO_File
  echo "set ptj 20."                              >> $FO_File
  echo "set drjj 0.4"                             >> $FO_File
  echo "set mass 9900032 10"                      >> $FO_File
  echo "set mass 25 125"                          >> $FO_File
  echo "set width 9900032 0.01"                   >> $FO_File
  echo "set systematics_program none"             >> $FO_File
  echo "set systematics_arguments []"             >> $FO_File
  $MG $FO_File 
fi

rm py.py MG_setup_FO*.dat  MG_setup_RS.dat MG5_debug 

