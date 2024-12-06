#!/bin/bash

#SAMPLES=("Pt-60To65_1366782" "Pt-65To70_1366783" "Pt-70To75_1366784" "Pt-75To80_1366785" "Pt-80To85_1366786" "Pt-85To90_1366787" "Pt-90To100_1366788" "Pt-100To140_1366789" "Pt-140To200_1366790" "Pt-200To9999_1366792")

zpmass=${1}

#############
### setup ###
#############

echo ""
now=$(date +"%T")
echo "Starting time : $now"
echo ""
echo ""

Singularity_Loc=/data6/Users/taehee/HerwigWD/
Hw_Loc=/data6/Users/taehee/HerwigWD/
WD=$Hw_Loc/hw7_validation/FullShower/HAHM/13TeV/QCD_M5_13TeV-mg-hw/

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
rm -rf yoda_${zpmass}
mkdir yoda_${zpmass}
cd yoda_${zpmass}

source "$Hw_Loc/bin/activate"

# run rivet
echo "#########################"
echo "# Merge and Stack Yodas #"
echo "#########################"
index=0
for sample in "${SAMPLES[@]}"; do
    yodafiles=$(find /gv0/Users/taehee/HerwigSample/hw/MZp-${zpmass}/${sample}/ -type f -name "LHC.yoda")
    yodamerge -o "LHC-$index.yoda" $yodafiles
    index=$((index + 1))
done
yodastack -o LHC.yoda LHC-*.yoda

cd $WD

echo ""
now=$(date +"%T")
echo "End time : $now"
echo ""
echo ""
