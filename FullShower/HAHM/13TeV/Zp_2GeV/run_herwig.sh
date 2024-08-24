#!/bin/bash

echo ""
now=$(date +"%T")
echo "Starting time : $now"
echo ""
echo ""

#############
### setup ###
#############

CompileUFO=true
UFOName=HAHM_variableMW_v3_UFO
EVTpRUN=100000

Singularity_Loc=/data6/Users/joonblee/hw_singularity
Hw_Loc=/data6/Users/joonblee/hw_singularity/
WD=$Hw_Loc/hw7_validation/FullShower/HAHM/13TeV/Zp_2GeV

# Herwig7 basic setups
#ln -s $(which python3) $Singularity_Loc/.local/bin/python
export PATH=$Singularity_Loc/.local/bin:$PATH
export LIBTOOL=$Singularity_Loc/.local/bin/libtool
export LIBTOOLIZE=$Singularity_Loc/.local/bin/libtoolize
export ACLOCAL_PATH=$Singularity_Loc/.local/share/aclocal:$ACLOCAL_PATH
export PATH="$Singularity_Loc/.pyenv/bin:$PATH"
export PYENV_ROOT=$Singularity_Loc/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYTHONUSERBASE=$Singularity_Loc/.pyenv
export PATH=$PYTHONUSERBASE/bin:$PATH
export LDFLAGS="-L$Singularity_Loc/.local/lib"
export CPPFLAGS="-I$Singularity_Loc/.local/include"
export PKG_CONFIG_PATH="$Singularity_Loc/.local/lib/pkgconfig"

###########
### run ###
###########

current_dir=$PWD
cd $WD

rnum=$(shuf -i 1-99999999 -n 1)
mkdir tmp_$rnum
cp RAnalysis.cc tmp_$rnum/
cd tmp_$rnum

RB="$Hw_Loc/bin/rivet-build"
source "$Hw_Loc/bin/activate"

# compiling ufo file
if [ "$CompileUFO" = true ] && [ ! -f FRModel.model ]; then
  if [[ ! -d ${UFOName} ]]; then
    echo "${UFOName} folder does not exist."
    echo "Check if ${UFOName} exists..."
    if [[ ! -f "${UFOName}.tar.gz" ]]; then
      echo "${UFOName} does not exist."
      echo "Install from the cms web."
      wget https://cms-project-generators.web.cern.ch/cms-project-generators/HAHM_variableMW_v3_UFO.tar.gz
    fi
    echo "Untar the tar ball."
    tar -zxvf HAHM_variableMW_v3_UFO.tar.gz
    sed -i "39s/20/2./" ${UFOName}/parameters.py
  fi
  ufo2herwig ${UFOName} --enable-bsm-shower --convert
  sed -i "s/echo \*.cc/echo FRModel*.cc/g" Makefile
  sed -i "36,114s/^/#/" FRModel.model
  sed -i "187,272s/^/#/" FRModel.model
  make
fi

# compile rivet analysis
echo "Compile the rivet analysis, RAnalysis.cc"
$RB Rivet.so RAnalysis.cc
export RIVET_ANALYSIS_PATH=$WD/tmp_$rnum
echo ""

# run hw7
echo "Start runnning LHC-${i}"
sed -e "s/__NEVENTS__/${EVTpRUN}/g" ${WD}/LHC.in > ${WD}/tmp_$rnum/LHC-${rnum}.in
sed -i "s/__SEED__/${rnum}/g"                      ${WD}/tmp_$rnum/LHC-${rnum}.in
sed -i "s/__RUN__/${rnum}/g"                       ${WD}/tmp_$rnum/LHC-${rnum}.in
Herwig read LHC-${rnum}.in
Herwig run LHC-${rnum}.run

rm -rf *FR* ${UFOName}* __pycache__ Makefile param_card.dat RAnalysis.* *tex *out
cd $current_dir

echo ""
now=$(date +"%T")
echo "End time : $now"
echo ""
echo ""

