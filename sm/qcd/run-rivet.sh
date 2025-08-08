# singularity shell --env LC_ALL=C /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-ubuntu-20.04:latest
# bash # To use nominal bash script, i.e. ~/.bashrc

#!/bin/bash

#############
### setup ###
#############

Ncore=72

CompileRivet=true
makehtml=false

this_dir=$PWD
ANALYSIS_NAME="RAnalysis"

RUN_FO=true
RUN_RS=true
RUN_QCD=true

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

# run QCD
if $RUN_QCD; then
  echo " Setting up for QCD"
  HepMC_FILES=(./QCD-*/QCD.hepmc)
  if [ ${#HepMC_FILES[@]} -eq 0 ]; then
    echo "No HepMC files found in target directory."
    return 1
  fi
  
  process_file() {
    FILE="$1"
    DIRNAME=$(basename "$(dirname "$FILE")")  # e.g., QCD-1
    rivet -a "$ANALYSIS_NAME":sample=QCD -o "${DIRNAME}.yoda" "$FILE" &> "${DIRNAME}.log"
  }
  export -f process_file
  export ANALYSIS_NAME
  
  echo " Start running"
  printf "%s\n" "${HepMC_FILES[@]}" | xargs -P $Ncore -n 1 -I {} bash -c 'process_file "$@"' _ {}
  yodamerge -o QCD.yoda ${this_dir}/QCD-*.yoda
  sed -i "s/:sample=QCD//g" QCD.yoda
  mv QCD-1.yoda tmp_QCD.yoda
  mv QCD-1.log tmp_QCD.log
  rm QCD-*.yoda QCD-*.log
  echo ""
fi

# Signal FO
if $RUN_FO; then
  echo " Setting up for FO"
  TARGET_DIR="/gv0/Users/taehee/PhenoHW/MZp-10_FO_jet"
  # TARGET_DIR="/gv0/Users/taehee/PhenoHW/MZp-10_FO_Gen"
  HepMC_FILES=(${TARGET_DIR}/LHC_*.hepmc)
  # HepMC_FILES=(${TARGET_DIR}/LHC_1.hepmc)
  if [ ${#HepMC_FILES[@]} -eq 0 ]; then
    echo "No HepMC files found in target directory."
    return 1
  fi
  
  process_file() {
    FILE="$1"
    BASENAME=$(basename "$FILE" .hepmc)
    rivet -a $ANALYSIS_NAME:sample=FO -o "${BASENAME}.yoda" "$FILE" &> "${BASENAME}.log"
  }
  export -f process_file
  export ANALYSIS_NAME
  
  echo " Start running"
  printf "%s\n" "${HepMC_FILES[@]}" | xargs -P $Ncore -n 1 -I {} bash -c 'process_file "$@"' _ {}
  yodamerge -o FO.yoda ${this_dir}/LHC_*.yoda
  sed -i "s/:sample=FO//g" FO.yoda
  mv LHC_1.yoda tmp_FO.yoda
  mv LHC_1.log tmp_FO.log
  rm LHC_*.yoda LHC_*.log
  echo ""
fi

# Signal RS
if $RUN_RS; then
  echo " Setting up for RS"
  TARGET_DIR="/gv0/Users/taehee/PhenoHW/MZp-10_RS_jet"
  # TARGET_DIR="/gv0/Users/taehee/PhenoHW/MZp-10_RS_Gen"
  HepMC_FILES=(${TARGET_DIR}/LHC_*.hepmc)
  # HepMC_FILES=(${TARGET_DIR}/LHC_[123456789].hepmc) # for test
  if [ ${#HepMC_FILES[@]} -eq 0 ]; then
    echo "No HepMC files found in target directory."
    return 1
  fi
  
  process_file() {
    FILE="$1"
    BASENAME=$(basename "$FILE" .hepmc)
    echo $FILE
    rivet -a ${ANALYSIS_NAME}:sample=RS -o "${BASENAME}.yoda" "$FILE" &> "${BASENAME}.log"
  }
  export -f process_file
  export ANALYSIS_NAME
  
  echo " Start running"
  printf "%s\n" "${HepMC_FILES[@]}" | xargs -P $Ncore -n 1 -I {} bash -c 'process_file "$@"' _ {}
  yodamerge -o RS.yoda ${this_dir}/LHC_*.yoda
  sed -i "s/:sample=RS//g" RS.yoda
  
  mv LHC_1.yoda tmp_RS.yoda
  # mv LHC_1.log tmp_RS.log
  cat LHC_[123456789].log > tmp_RS.log
  rm LHC_*.yoda LHC_*.log
  echo ""
fi

#rivet -a RAnalysis -o /gv0/Users/taehee/PhenoHW/MZp-10_FO_jet/LHC_*.hepmc &> rivet_MZp-10_FO_jet.log &
#rivet -a RAnalysis -o /gv0/Users/taehee/PhenoHW/MZp-10_RS_jet/LHC_*.hepmc &> rivet_MZp-10_FO_jet.log &

# run rivet
if $makehtml; then
  echo "#########################"
  echo "# ----- Run rivet ----- #"
  echo "#########################"
  rivet-mkhtml QCD.yoda FO.yoda RS.yoda;
fi
 
deactivate

# Clear directory
#mkdir tmp
echo ""
now=$(date +"%T")
echo "End time : $now"

echo ""
echo "done"
echo ""
