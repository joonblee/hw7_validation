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

Hw_Loc=/data6/Users/taehee/HerwigWD
Singularity_Loc=$Hw_Loc
WD=$Hw_Loc/hw7_validation/FullShower/HAHM/13TeV/mg
mg_job_number=${3}

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

cd $WD
outputdir=/gv0/Users/taehee/HerwigSample/hw/${mg_job_number}/${2}
echo "Working Directory: $WD"
echo "Make a run directory, $outputdir"

mkdir -p ${outputdir}
cp ../QCD_M5_13TeV-mg-hw/RAnalysis.cc ${outputdir}
cd ${outputdir}

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
    sed -i "39s/20/5./" ${UFOName}/parameters.py
  fi
  ufo2herwig ${UFOName} --enable-bsm-shower --convert
  sed -i "s/echo \*.cc/echo FRModel*.cc/g" Makefile
  sed -i "36,114s/^/#/" FRModel.model
  sed -i "187,272s/^/#/" FRModel.model
  make
fi

# compile rivet analysis
echo "Compile the rivet analysis, RAnalysis.cc"
chmod +x $RB
$RB Rivet.so RAnalysis.cc
export RIVET_ANALYSIS_PATH=$outputdir
echo ""

# run hw7
echo "Start runnning LHC.${1}.${2} (mg job # = ${mg_job_number})"
rnum=$(shuf -i 1-99999999 -n 1)
sed -e "s/__NEVENTS__/${EVTpRUN}/g" ${WD}/../QCD_M5_13TeV-mg-hw/LHC.in > ${outputdir}/LHC.in
sed -i "s/__SEED__/${rnum}/g" "${outputdir}/LHC.in"
sed -i "s/__DIR__/\/gv0\/Users\/taehee\/HerwigSample\/mg\/${mg_job_number}\/${2}/g" "${outputdir}/LHC.in"
Herwig read LHC.in 
Herwig run LHC.run 

rm -rf *FR* ${UFOName}* __pycache__ Makefile param_card.dat RAnalysis.* *tex *out
cd $WD

echo ""
now=$(date +"%T")
echo "End time : $now"
echo ""
echo ""
