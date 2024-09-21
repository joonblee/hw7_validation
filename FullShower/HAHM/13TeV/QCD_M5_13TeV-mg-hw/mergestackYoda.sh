#!/bin/bash

mg_job_numbers=("2491183_50_80" "2491184_80_120" "2491185_120_170" "2491186_170_300" "2491187_300_470" "2491188_470_600" "2491189_600_800" "2491190_800_1000" "2491191_1000_9999")

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
mkdir yoda
cd yoda

source "$Hw_Loc/bin/activate"

# run rivet
echo "#########################"
echo "# Merge and Stack Yodas #"
echo "#########################"
index=0
for job_number in "${mg_job_numbers[@]}"; do
    yodafiles=$(find /gv0/Users/taehee/HerwigSample/hw/$job_number/ -type f -name "LHC.yoda")
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
