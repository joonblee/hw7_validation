#!/bin/bash

#############
### setup ###
#############
runRS=true
runFO=true
runDF=false

rm -rf FO*-EvtGen.log FO*-run*.log FO*.out FO*.run FO*.tex RS-EvtGen.log RS-run.log RS.out RS.run RS.tex rivet-plots

Hw_Loc=/home/joonblee/WD/Herwig
MG_version="MG5_aMC_v3_3_2"

nevents=1000000
ebeam=500

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
  echo "import model 2HDM"                     >> $RS_File
  echo "generate e+ e- > b b~"                 >> $RS_File
  echo "output madevent $RS_DIR"               >> $RS_File
  echo "launch"                                >> $RS_File
  echo "set nevents $nevents"                  >> $RS_File
  echo "set ebeam1 $ebeam"                     >> $RS_File
  echo "set ebeam2 $ebeam"                     >> $RS_File
  echo "set mass 25 125"                       >> $RS_File
  echo "set mass 35 10"                        >> $RS_File
  echo "set width 35 0.01"                     >> $RS_File
  echo "set systematics_program none"          >> $RS_File
  echo "set systematics_arguments []"          >> $RS_File
  $MG $RS_File 
fi

# setup file for FO to be stored
if $runFO;then
  FO_File="MG_setup_FO.dat"
  FO_DIR=FO
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
  echo "set mass 35 10"                        >> $FO_File
  echo "set width 35 0.01"                     >> $FO_File
  echo "set systematics_program none"          >> $FO_File
  echo "set systematics_arguments []"          >> $FO_File
  $MG $FO_File 
fi

# setup file for diagram filter(DF) to be stored
if $runDF;then
  DF_File="MG_setup_DF.dat"
  DF_DIR=DF
  cp MG_filter/only_radiation.py ${Hw_Loc}/opt/MG5_aMC_v3_3_2/PLUGIN/user_filter.py
  if [ -d "$DF_DIR" ]; then
    echo "$DF_DIR exists, erase"
    rm -rf $DF_DIR
  fi
  echo "set auto_update 0"                                  >> $DF_File
  echo "import model 2HDM"                                  >> $DF_File
  echo "generate e+ e- > b | b~ > b b~ h2 --diagram_filter" >> $DF_File
  echo "output madevent $DF_DIR"                            >> $DF_File
  echo "launch"                                             >> $DF_File
  echo "set nevents $nevents"                               >> $DF_File
  echo "set ebeam1 $ebeam"                                  >> $DF_File
  echo "set ebeam2 $ebeam"                                  >> $DF_File
  echo "set etab 5."                                        >> $DF_File
  echo "set mass 25 125"                                    >> $DF_File
  echo "set mass 35 10"                                     >> $DF_File
  echo "set width 35 0.01"                                  >> $DF_File
  echo "set systematics_program none"                       >> $DF_File
  echo "set systematics_arguments []"                       >> $DF_File
  $MG $DF_File 
fi

rm py.py MG_setup_FO.dat MG_setup_DF.dat MG_setup_RS.dat MG5_debug 

