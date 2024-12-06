# 1. How to install Hw7

Herwig works under Ubuntu 20.X with 
```
$ sudo apt -y install gcc g++ gfortran automake autoconf libtool tar make emacs wget openssl mercurial git
$ sudo apt-get -y install libssl-dev # instead of openssl-devel
$ sudo apt-get -y install python3-pip
$ sudo pip3 install cython sympy scipy  six
$ sudo apt-get cmake
```
To install an official version, one can get `herwig-bootstrap` file from the herwig homepage and just do `./herwig-bootstrap -j 4 $PWD`.
```
$ wget https://herwig.hepforge.org/downloads/herwig-bootstrap
$ chmod +x herwig-bootstrap
$ ./herwig-bootstrap -j 4 $PWD
```

If you want to utilize BSM PS before HW7.4 release, you need to have up-to-date `herwig-bootstrap` code. BSM PS has been merged into the trunk (i.e. HW central repo), but not released yet. Please `git clone` this repo and use `herwig-bootstrap` file in there. In other words, one can do
```
mkdir herwig
cd herwig
git clone https://github.com/joonblee/hw7_validation.git
cp hw7_validation/herwig-bootstrap ./
chmod +x herwig-bootstrap
./herwig-bootstrap -j 4 $PWD --herwig-hg --thepeg-hg --thepeg-version="default" --herwig-version="default"
```
See the "Trouble shooting" section if you met any errors while installing HW7.

Now everything is ready.
One can run herwig referring `https://herwig.hepforge.org/tutorials/gettingstarted/firstrun.html`, while I recommend to use my validation code as described in the next section.


## Trouble shooting

1. After re-installing Ubuntu, I've got a following errors: 
```
/usr/bin/env: %%% ‘python’: No such file or directory.
```
This can be solved by $ sudo apt install python-is-python3)

2. In TH's desktop, there is no gengetopt so do `$ sudo apt-get install -y gengetopt`, then 
```
$ chmod +x herwig-bootstrap
$ ./herwig-bootstrap -j 4 ./
```
should work.

3. Errors on subprograms
Use `--without-PROGRAM` option when some programs are not installed due to the network error, e.g. `--without-vbfnlo`.

4. Errors on building UFO model
When testing Neda's model, I've faced an error during compiling the UFO file. What I did is as follow:

```
$ ufo2herwig 2HDM+CS --enable-bsm-shower
  ### My desktop uses python3, so when I dealt with other UFO model file I always use --convert. But in this time, it looks that Neda's model is built under python3 as well. Is it right? I thus didn't use the convert option for Neda's model. I hope it doesn't make any problem.
  ### In any case this command does not give any error

$ make
  ### Here I've got an error as shown in [1]
```

To solve this problem, I builded a local copy of the gcc compilers following:
```
$ ./herwig-bootstrap -j 4 --build-gcc ./ 
```

[1] Error during 'make'
```
g++ -std=c++11 -fPIC -I/home/joonblee/WD/Herwig/./include -I/home/joonblee/WD/Herwig/.//include -I/home/joonblee/WD/Herwig/.//include -Wall -Wextra -pedantic -O2 -DBOOST_UBLAS_NDEBUG -c FRModel.cc -o FRModel.o
g++ -std=c++11 -fPIC -I/home/joonblee/WD/Herwig/./include -I/home/joonblee/WD/Herwig/.//include -I/home/joonblee/WD/Herwig/.//include -Wall -Wextra -pedantic -O2 -DBOOST_UBLAS_NDEBUG -c FRModel.cc -o FRModel.o
g++: internal compiler error: Segmentation fault signal terminated program cc1plus
Please submit a full bug report,
with preprocessed source if appropriate.
See <file:///usr/share/doc/gcc-9/README.Bugs> for instructions.
make: *** [Makefile:37: FRModel.o] Error 4
```

5. `aclocal` error

Error log (exit status 63):
```
autoreconf -vi
autoreconf: Entering directory `.'
autoreconf: configure.ac: not using Gettext
autoreconf: running: aclocal -I m4
configure.ac:3: error: Autoconf version 2.71 or higher is required
configure.ac:3: the top level
autom4te: /usr/bin/m4 failed with exit status: 63
aclocal: error: echo failed with exit status: 63
autoreconf: aclocal failed with exit status: 63
Traceback (most recent call last):
  File "./herwig-bootstrap", line 991, in <module>
    checkout(src_dir,"ThePEG",opts.thepeg_ver,opts.thepeg_repo,branch)
  File "./herwig-bootstrap", line 509, in checkout
    check_call(["autoreconf","-vi"])
  File "./herwig-bootstrap", line 488, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 364, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['autoreconf', '-vi']' returned non-zero exit status 63.
```
You can check your autoconf version by `/usr/local/bin/autoconf --version`. If the version is lower than 2.71, please reinstall newer autoconf by using following commands.
```
$ sudo apt-get update
$ sudo apt-get remove autoconf
$ sudo apt-get install build-essential m4
$ wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
$ tar -xzf autoconf-2.71.tar.gz
$ cd autoconf-2.71
$ ./configure
$ make
$ sudo make install
```

Error log (exit status 2):
```
autoreconf -vi
autoreconf: export WARNINGS=
autoreconf: Entering directory '.'
autoreconf: configure.ac: not using Gettext
autoreconf: running: aclocal -I m4
Can't exec "aclocal": No such file or directory at /usr/local/share/autoconf/Autom4te/FileUtils.pm line 299.
autoreconf: error: aclocal failed with exit status: 2
Traceback (most recent call last):
  File "./herwig-bootstrap", line 1397, in <module>
    checkout(src_dir,"TheP8I","",opts.thep8i_repo,branch,'git')
  File "./herwig-bootstrap", line 541, in checkout
    check_call(["autoreconf","-vi"])
  File "./herwig-bootstrap", line 498, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 364, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['autoreconf', '-vi']' returned non-zero exit status 2.
```

Solution:
```
$ sudo apt-get install automake
```

6. `libgsl` error

Error log:
```
checking if THEPEGPATH is set... yes (/home/joonblee/WD/herwig74pre)
checking if the installed ThePEG works... yes 
checking for gsl location... in system libraries
checking for sqrt in -lm... yes 
checking for cblas_srot in -lgslcblas... no
checking for gsl_ran_poisson in -lgsl... no
configure: error: Cannot find libgsl. Please install the GNU scientific library.
Traceback (most recent call last):
  File "./herwig-bootstrap", line 1712, in <module>
    check_call(args)
  File "./herwig-bootstrap", line 498, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 364, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['./configure', '--prefix=/home/joonblee/WD/herwig74pre', '--with-pythia8=/home/joonblee/WD/herwig74pre', 'THEPEGPATH=/home/joonblee/WD/herwig74pre']' returned non-zero exit status 1.
```
Solution:
```
$ sudo apt-get install libgsl-dev
```

## [For developers] Old method

Now remove the original herwig and install herwigbsm repo using mercurial.
```
$ rm src/herwig_bootstrap_thepeg_2_2_3_done
$ rm -rf src/Herwig-7.2.3*
$ ./herwig-bootstrap $PWD --herwig-hg --thepeg-hg --herwig-repo=ssh://vcs@phab.hepforge.org/diffusion/547/herwigbsm/
```
If `ThePEG/Herwig` doesn't install properly then use
```
$ cd src
$ rm herwig_bootstrap_thepeg_2_2_3_done
$ rm herwig_bootstrap_herwig_7_2_3_done
$ rm -rf ThePEG-2.2.3*
$ rm -rf Herwig-7.2.3*
$ hg clone https://phab.hepforge.org/source/thepeghg/ ThePEG-2.2.3
$ cd ThePEG-2.2.3
$ autoreconf -vi
$ cd ..
$ hg clone https://phab.hepforge.org/diffusion/547/herwigbsm/ Herwig-7.2.3
$ cd Herwig-7.2.3
$ autoreconf -vi
$ cd ../..
$ ./herwig-bootstrap -j 4 ./
```
Note that the order of `autoreconf -vi` and `hg clone`.
Inverting the order may cause an error.
Or equivalently, use as below:
```
$ ./herwig-bootstrap $PWD --herwig-hg --thepeg-hg --herwig-repo=ssh://vcs@phab.hepforge.org/diffusion/547/herwigbsm/ --herwig-version=default
```

### Trouble shooting

* Crash between ThePEG and herwigbsm (after Jan 2023)

When I came back from the national military service, I fould a crash between the up-to-date ThePEG and herwigbsm versions. I bypassed this problem by recalling the old ThePEG version.
```
$ cd src/ThePEG-2.2.3
$ hg log               % Check update logs and parallely watch https://phab.hepforge.org/diffusion/pushlog/?repositories=PHID-REPO-opcwldc6csinoqfiunqi.
$ hg update -r 2181    % Go back to the previous ThePEG version updated in OCT2022.
$ autoreconf -vi
$ cd ../Herwig-7.2.3/
$ autoreconf -vi
$ cd ../..
$ ./herwig-bootstrap ./ --without-openloops
```

# 2. How to run validation code

After correctly installing herwig, you can direcly run herwig and rivet with this repo.

- `OneFSR` directory: Generate all validation plots in the paper, JHEP08(2024)064, which compares fixed-order calculation from MG5 and a single FSR process from HW7 without additional shower, decay, and so on.
- `FullShower` directory: Simulate full shower.

For example, if you want to test dark photon shower from $pp\rightarrow jj$ process at $\sqrt{s} =$ 13 TeV with $m(Z') =$ 2 GeV, one can simply do
```
cd FullShower/HAHM/13TeV/Zp_2GeV/
source batch_run.sh
```
This automatically installs the HAHM model file, build rivet analysis, run herwig, and draw plots.
Note you should change the herwig location on L31 in `batch_run.sh` properly.
This should be the location where you run the bootstrap.
If all things go well, you should be able to see a `rivet-plots` directory.


## Note

- `LHC.in`: This file contains all necessary ingredients to run herwig, i.e. basic setups for pp collison, an hard process, parton shower, decay, event numbers, random seeds, and so on.
- `RAnalysis.cc`: This file is responsible for rivet analysis. One can change plot definitions or event selections here.
- `batch_run.sh`: This file actually activates and runs herwig, i.e. all things described in `https://herwig.hepforge.org/tutorials/gettingstarted/firstrun.html` were already written in this file.


## [For developers] Aidin's code
How to run Aidin's validation code, in `ssh://vcs@phab.hepforge.org/diffusion/548/herwig-bsm-notes/`?
(Up-to-date validation repo: https://github.com/joonblee/hw7_validation/tree/main)

### How to run?
First clone the code:
```
$ cdhw
$ mkdir test
$ cd test
$ hg clone ssh://vcs@phab.hepforge.org/diffusion/548/herwig-bsm-notes/
$ source /PATH/TO/HW7/bin/activate
$ cd /PATH/TO/ZH
$ chmod +x Build_LHE.sh 
$ ./Build_LHE.sh 
```
This will give `Rivet.sh` and folders: `ZH/` and `ZHH/`.
Aidin told if I change the rivet analysis class, `MCEWHHH.cc`, I should do `$ rivet-build Rivet.so MCEWHHH.cc` to get the .so library up to speed.
Refer "https://gitlab.com/hepcedar/rivet/blob/release-3-1-x/doc/tutorials/simple-analysis.md" for rivet analysis.
When I run FO.in file I've got an rivet error:
```
$ Herwig read FO.in 
Rivet.Analysis.Handler: WARN  Analysis 'MCEWHHH' not found.
Error: Rivet could not find all requested analyses.
Use 'rivet --list-analyses' to check availability.
```
When I check the rivet analyses list(`$ rivet --list-analyses OR $ rivet --show-analysis MCEWHHH`), there does not exist `MCEWHHH`. I thus run
```
$ export RIVET_ANALYSIS_PATH=$PWD
```
Then `$ rivet --list-analyses` shows that `MCEWHHH` is added into the list.
Finally we can run Herwig properly.
```
$ Herwig read FO.in
$ Herwig run FO.run
```

### Issue-1
To run Aidin's validation code(ZH), I update MG5 version to 3.3.2 as follows:
```
$ rm -rf opt/MG5_*
$ rm src/herwig_bootstrap_madgraph_done
$ ./herwig-bootstrap -j 4 ./ --madgraph-version=3.3.2
```

### Issue-2
When I run the validation code and run MG5, I've got an error which cannot find NNPDF23_ls_as_0130_qed.

#### method 1: 
I thus install it seperately.
```
$ source bin/activate 
$ lhapdf install NNPDF23_lo_as_0130_qed
```

#### method 2: 
Install lhapdf6 in madgraph seperately. -> launch madgraph and do "install lhapdf6".

#### method 3: Use LHAPDF6 in herwig7, which is installed by the bootstrap code. 
set lhapdf /PATH/TO/lhapdf-config
in MG5 UI.

Note method 1 does not work in some cases.
Use method 2 or 3.


# 3. BSM model

Install 2HDMtII_NLO file from `https://feynrules.irmp.ucl.ac.be/raw-attachment/wiki/2HDM/2HDMtII_NLO.tar.gz`
```
$ cd /go/to/test/directory
$ tar xzf 2HDMtII_NLO.tar.gz
$ ufo2herwig 2HDMII_NLO --enable-bsm-shower --convert
$ make
```

*** If there is any other `*.cc` files in current directory without `FRModel.cc` then the `make` (based on `Makefile`) compile all `*.cc` files and make some troubles. Troubleshouting: modify Makefile `*.cc` -> `FRModel*.cc`.
*** When you successfully run `ufo2herwig` but get some errors after `make` such as `cannot find FRModel.so` (which is nominally due to another `*.cc` files in the directory), you should erase the model directory (i.e. 2HDMtII_NLO in this case) because it might already include some errors inside

Note FCNC modes are not allowed by default. One can allow this with
```
ufo2herwig /address/to/ufo --enable-bsm-shower --allow-fcnc
```


# 4. How to run rivet
Before running rivet, we should install latex and image magic.
```
$ sudo apt install -y texlive-full % I first install texlive-latex-base as '$ sudo apt install texlive-latex-base', which only installs a minimal latex. However it doesn't work properly. '$ make-plots test.dat' doesn't make any plot. (All types of image files such as ps, eps, pdf, png files are not generated.)
$ sudo apt install imagemagick-6.q16
```
Finally we can make some plots with Rivet using below commands:
```
$ rivet-mkhtml FO.yoda
```

## Useful notes
One can merge two yoda files with `yodamerge -o [Output File].yoda [First Input].yoda [Second Input].yoda` which averages two yoda files. If you want to stack (add up) two files directly, do ``yodastack -o [Output File].yoda [First Input].yoda [Second Input].yoda`.


# 5. [For developers] How to push updates on my local repo to the remote repo?

First pull the remote repository to sync my local repository.
```
// $ hg pull ssh://vcs@phab.hepforge.org/diffusion/547/herwigbsm/
// $ hg update
$ hg pull ssh://vcs@phab.hepforge.org/diffusion/548/herwig-bsm-notes/
$ hg status -am    # 'hg status' shows the status of all files. 'M': modified, 'A': added, '?': not tracked by Mercurial. '-am' option only shows 'M' and 'A' files.
```
Now we need to commit the changes in the local directory. Note this command does not touch the remote repository, but only let your local Mercurial know what the changes are.
```
$ hg commit -m "message" --exclude folder/ file1 file2 ...
```
The `--exclude` options excludes the files when it commits. Equivalently we can use `$ hg add --exclude file1 file2; hg commit -m "message"`.
Finally we can push the changes by
```
$ hg push
```
This will change your remote repository.

If you get an error during push,
```
$ hg push
pushing to https://phab.hepforge.org/diffusion/547/herwigbsm/
abort: error: No address associated with hostname
```
Probably due to https error. Do the following command:
```
$ hg push ssh://vcs@phab.hepforge.org/diffusion/547/herwigbsm/
```


# 6. Install HW7 with singularity

## (1) Prepare singularity
### For tamsa1

If one considers to run HW7 in tamsa1, singularity is neccesary to install HW7.
Here is a short instruction.
```
singularity pull docker://opensciencegrid/osgvo-ubuntu-20.04
singularity build --sandbox herwig_sandbox osgvo-ubuntu-20.04_latest.sif
singularity shell --writable herwig_sandbox
mkdir -p /data6/Users/[user_name]/[wroking_directory] 
exit
singularity shell --writable --bind /data6/Users/joonblee herwig_sandbox/
bash
```
Note it necessitates making a `/data6` working directory in the sandbox before binding, if you want to work under `/data6`, because there is no `/data6` directory in the sandbox, which makes binding fail.

### For cms1

In cms1, one can run singularity directly as follow:
```
singularity shell --env LC_ALL=C /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-ubuntu-20.04:latest
bash # To use nominal bash script, i.e. ~/.bashrc
```

### For KNU, KISTI
```
singularity pull docker://opensciencegrid/osgvo-ubuntu-20.04
singularity shell --env LC_ALL=C osgvo-ubuntu-20.04_latest.sif
```

### Common

To use bash commands only in this singularity, one should make `vi ~/.bashrc.singularity` (You can edit this file however you want. I'll explain later what actually needs to add inside.) and add following lines in the `~/.bashrc` file:
```
# Source .bashrc.singularity if inside a Singularity container
if [ -n "$SINGULARITY_NAME" ]; then
    source ~/.bashrc.singularity
fi
```
This will automatically execute `~/.bashrc.singularity` when you start a new singularity.

Now the singularity is ready.
We need to install some dependencies.


## (2) Prepare dependencies
### For tamsa1 / KNU / KISTI

There is a missing point in this script. Carefully check all things are set properly.

```
WD=$PWD

mkdir -p $PWD/.local/bin
mkdir -p $PWD/.local/src

cd $WD/.local/src
curl -L -o pyenv.tar.gz https://github.com/pyenv/pyenv/archive/refs/heads/master.tar.gz
tar -xzf pyenv.tar.gz
mkdir -p $WD/.pyenv
mv pyenv-master/* $WD/.pyenv/
git clone https://github.com/pyenv/pyenv-virtualenv.git $WD/.pyenv/plugins/pyenv-virtualenv
export PATH="$WD/.pyenv/bin:$PATH"
export PYENV_ROOT=$WD/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# install bzip2 to avoid the error during python 2.7.18 installation
cd $WD/.local/src
wget https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
tar -xzf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
make -f Makefile-libbz2_so
make install PREFIX=$WD/.local
export LDFLAGS="-L$WD/.local/lib"
export CPPFLAGS="-I$WD/.local/include"
export PKG_CONFIG_PATH="$WD/.local/lib/pkgconfig"

# install Tk toolkit to avoid the error during python 3.8.10 installation
cd $WD/.local/src
wget https://prdownloads.sourceforge.net/tcl/tcl8.6.10-src.tar.gz
wget https://prdownloads.sourceforge.net/tcl/tk8.6.10-src.tar.gz
tar -xzf tcl8.6.10-src.tar.gz
tar -xzf tk8.6.10-src.tar.gz
cd tcl8.6.10/unix
./configure --prefix=$WD/.local
make
make install
cd $WD/.local/src/tk8.6.10/unix
./configure --prefix=$WD/.local --with-tcl=$WD/.local/lib
make
make install

pyenv install 2.7.18
LDFLAGS="-L$WD/.local/lib" CPPFLAGS="-I$WD/.local/include" PKG_CONFIG_PATH="$WD/.local/lib/pkgconfig" pyenv install 3.8.10
pyenv global 3.8.10 2.7.18
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
rm get-pip.py
pip3 install --user six 

export PYTHONUSERBASE=$WD/.pyenv
export PATH=$PYTHONUSERBASE/bin:$PATH
pip install --user cython
pip install --user mercurial

ln -s $(which python3) $WD/.local/bin/python
### for tamsa1 # not sure it really necessitates
# 'which python3' doesn't work in e.g. cms1, so replace it to 'command -v python3'
export PATH=$WD/.local/bin:$PATH

cd $WD/.local/src/
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
tar -xzf autoconf-2.71.tar.gz
cd autoconf-2.71
./configure --prefix=$WD/.local
make
make install

cd $WD/.local/src/
wget http://ftpmirror.gnu.org/libtool/libtool-2.4.7.tar.gz
tar -xzf libtool-2.4.7.tar.gz
cd libtool-2.4.7
./configure --prefix=$WD/.local
make
make install
# v.2.4.6 brings an error during Herwig installation

export LIBTOOL=${WD}/.local/bin/libtool
export LIBTOOLIZE=${WD}/.local/bin/libtoolize
export ACLOCAL_PATH=${WD}/.local/share/aclocal:$ACLOCAL_PATH

pip install numpy

cd $WD
```
To prepare you need to re-install Herwig7 again next time, it is handy to add the following lines to `~/.bashrc.singularity` in advance without repeating all these steps from the beginning:
```
# Herwig7 basic setups
ln -s $(which python3) $WD/.local/bin/python
export PATH=$WD/.local/bin:$PATH
export LIBTOOL=$WD/.local/bin/libtool
export LIBTOOLIZE=$WD/.local/bin/libtoolize
export ACLOCAL_PATH=$WD/.local/share/aclocal:$ACLOCAL_PATH
export PATH="$WD/.pyenv/bin:$PATH"
export PYENV_ROOT=$WD/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYTHONUSERBASE=$WD/.pyenv
export PATH=$PYTHONUSERBASE/bin:$PATH
export LDFLAGS="-L$WD/.local/lib"
export CPPFLAGS="-I$WD/.local/include"
export PKG_CONFIG_PATH="$WD/.local/lib/pkgconfig"
```


### For cms1

```
WD=$PWD

mkdir -p ~/.local/bin
mkdir -p ~/.local/src

ln -s $(command -v python3) ~/.local/bin/python
export PATH=$HOME/.local/bin:$PATH

pip install --user cython
pip install --user mercurial

cd ~/.local/src/
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
tar -xzf autoconf-2.71.tar.gz
cd autoconf-2.71
./configure --prefix=$HOME/.local
make
make install

cd ~/.local/src/
wget http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
tar -xzf libtool-2.4.6.tar.gz
cd libtool-2.4.6
./configure --prefix=$HOME/.local
make
make install

export LIBTOOL=${HOME}/.local/bin/libtool
export LIBTOOLIZE=${HOME}/.local/bin/libtoolize
export ACLOCAL_PATH=${HOME}/.local/share/aclocal:$ACLOCAL_PATH

cd ~/.local/src
curl -L -o pyenv.tar.gz https://github.com/pyenv/pyenv/archive/refs/heads/master.tar.gz
tar -xzf pyenv.tar.gz
mkdir -p ~/.pyenv
mv pyenv-master/* ~/.pyenv/
git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

cd ~/.local/src
wget https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
tar -xzf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
make -f Makefile-libbz2_so
make install PREFIX=$HOME/.local
export LDFLAGS="-L$HOME/.local/lib"
export CPPFLAGS="-I$HOME/.local/include"
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig"

pyenv install 2.7.18
pyenv install 3.8.10
pyenv global 3.8.10 2.7.18
pip3 install --user six

pip install numpy

cd $WD
```
To prepare you need to re-install Herwig7 again next time, it is handy to add the following lines to `~/.bashrc.singularity` in advance without repeating all these steps from the beginning:
```
# Herwig7 basic setups
ln -s $(command -v python3) ~/.local/bin/python
export PATH=$HOME/.local/bin:$PATH
export LIBTOOL=$HOME/.local/bin/libtool
export LIBTOOLIZE=$HOME/.local/bin/libtoolize
export ACLOCAL_PATH=$HOME/.local/share/aclocal:$ACLOCAL_PATH
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export LDFLAGS="-L$HOME/.local/lib"
export CPPFLAGS="-I$HOME/.local/include"
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig"
```


## (3) Install HW7

Finally, one can install herwig with 
```
mkdir herwig
cd herwig
git clone https://github.com/joonblee/hw7_validation.git
cp hw7_validation/herwig-bootstrap ./
chmod +x herwig-bootstrap
$ ./herwig-bootstrap -j 16 $PWD --herwig-hg --thepeg-hg --thepeg-version="default" --herwig-version="default"
```


Also, you should also install the PDF that you need. [LHAPDF](https://lhapdf.hepforge.org/pdfsets.html)
```
cd $WD/share/LHAPDF
wget http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF31_lo_as_0130.tar.gz
wget http://lhapdfsets.web.cern.ch/lhapdfsets/current/NNPDF31_nnlo_as_0118.tar.gz
tar xvf NNPDF31_lo_as_0130.tar.gz
tar xvf NNPDF31_nnlo_as_0118.tar.gz
```


### Optionals

#### Latex
`rivet-mkhtml` necessitates latex. Latex is quite large so I recommend to make plots outside the singularity. However, if you need to run it under singularity, follow below instructions

```
cd $WD/.local/src
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-[NUMBER] # Note you should set [NUNBER] properly
./install-tl --profile=$WD/custom.profile
# Because we didn't use sudo, it executes an interactive mode.
# Follow below instructions carefully to configure.
#
# 1. Choose <D> (D+enter) to set directories and set:
# TEXDIR: /data6/Users/joonblee/hw_singularity/.local/texlive/2024
# TEXMFLOCAL: /data6/Users/joonblee/hw_singularity/.local/texlive/texmf-local
# TEXMFSYSVAR: /data6/Users/joonblee/hw_singularity/.local/texlive/2024/texmf-var
# TEXMFSYSCONFIG: /data6/Users/joonblee/hw_singularity/.local/texlive/2024/texmf-config
# TEXMFVAR: /data6/Users/joonblee/hw_singularity/.local/texlive/2024/texmf-var
# TEXMFCONFIG: /data6/Users/joonblee/hw_singularity/.local/texlive/2024/texmf-config
# TEXMFHOME: /data6/Users/joonblee/hw_singularity/.local/texlive/texmf-home
# 2. Select <I> to proceed installation
export PATH=$WD/.local/texlive/2024/bin/x86_64-linux:$PATH
```


## (4) Submit condor jobs

Example codes to submit condor jobs in tamsa1 can be found in 

### a. QCD sample with Herwig7: `FullShower/HAHM/13TeV/QCD_M5_13TeV-hw/`.

To submit jobs, do
```
chmod +x hw_condor.sh
condor_submit submit_condor_hw.txt
```

#### Brief introduction of each file

- `submit_condor_hw.txt`: Actually submit condor jobs. One can change the singularity sandbox location and the number of jobs here.

For example, `queue` is the total number of samples:
```
queue [Number of jobs]
```

- `hw_condor.sh`: All the other general things are included in this shell script.

For example, the number of event and Z' mass can be set as follow:
```
EVTpRUN=[Number of event per job]
sed -i "39s/20/[Mass of Z' boson]/" ${UFOName}/parameters.py
```
At last, you will get [Number of jobs] \* [Number of event per job] events.

- `LHC.in`: Details to run Heriwg7.

For example, one should set proper centre-of-mass energy, coupling values, and decay channels here.
```
set EventGenerator:EventHandler:LuminosityFunction:Energy [Energy]\*GeV
set uuZpSplitFnEW:CouplingValue.Left.Im [Coupling value]
insert /Herwig/NewPhysics/DecayConstructor:DisableModes 0 Zp->c,cbar;
```

- `RAnalysis.cc`: Rivet analyzer.

- `hw_standalone.sh`: Run herwig individually without condor.

- `activate_herwig.sh`: Activate herwig7. Use this command when you want to test herwig commands one by one.


### b. QCD sample with MG5+HW7: `FullShower/HAHM/13TeV/QCD_M5_13TeV-mg-hw/`.

To submit jobs, do
```
chmod +x mg_condor.sh
condor_submit submit_condor_mg.txt
```
You will get a `mg/` directory which contains all MG5 outputs.
Herwig7 utilizes this output.
```
chmod +x hw_condor.sh
condor_submit submit_condor_hw.txt
```

#### Brief introduction of each file

- `submit_condor_mg.txt`: Submit condor jobs to generate MG (hard process) events. One can change the singularity sandbox location and the number of jobs here.

For example, `queue` is the total number of samples:
```
queue [Number of jobs]
```

- `mg_condor.sh`: All MG5 setups are included in this shell script.

For example, event numbers and beam energies are set in this file:
```
nevents=[Number of events per job]
ebeam=[Beam energy]
echo "set mzdinput [Z' mass]" >> $RS_File
```

- `submit_condor_hw.txt`: Submit condor jobs to simulate parton shower, decays, and so on. One can change the singularity sandbox location and the number of jobs here.

For example, `queue` is the total number of samples:
```
queue [Number of jobs]
```

- `hw_condor.sh`: All the other general things for HW7 are included in this shell script.

For example, the number of event and Z' mass can be set as follow:
```
EVTpRUN=[Number of event per job]
sed -i "39s/20/[Mass of Z' boson]/" ${UFOName}/parameters.py
```
At last, you will get [Number of jobs] \* [Number of event per job] events.

- `LHC.in`: Details to run Heriwg7.

For example, one should set proper centre-of-mass energy, coupling values, and decay channels here.
```
set EventGenerator:EventHandler:LuminosityFunction:Energy [Energy]\*GeV
set uuZpSplitFnEW:CouplingValue.Left.Im [Coupling value]
insert /Herwig/NewPhysics/DecayConstructor:DisableModes 0 Zp->c,cbar;
```

- `RAnalysis.cc`: Rivet analyzer.


If you need a specific model for the madgraph, you can install it following commands below.
```
# e.g., HAHM
cd $WD/opt/MG5_aMC_v3_5_1/models/
wget https://cms-project-generators.web.cern.ch/cms-project-generators/HAHM_variableMW_v3_UFO.tar.gz
tar zxf HAHM_variableMW_v3_UFO.tar.gz
```


## (5) Run HW7 without condor

### For tamsa1
```
singularity shell --writable --bind /data6/Users/joonblee herwig_sandbox/
bash
# Herwig7 basic setups
ln -s $(which python3) $WD/.local/bin/python
export PATH=$WD/.local/bin:$PATH
export LIBTOOL=$WD/.local/bin/libtool
export LIBTOOLIZE=$WD/.local/bin/libtoolize
export ACLOCAL_PATH=$WD/.local/share/aclocal:$ACLOCAL_PATH
export PATH="$WD/.pyenv/bin:$PATH"
export PYENV_ROOT=$WD/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYTHONUSERBASE=$WD/.pyenv
export PATH=$PYTHONUSERBASE/bin:$PATH
export LDFLAGS="-L$WD/.local/lib"
export CPPFLAGS="-I$WD/.local/include"
export PKG_CONFIG_PATH="$WD/.local/lib/pkgconfig"
```

## (6) Trouble shooting

This part is actually a repetation of the above section. If you had correctly followed the previous commands, you could have simply passed this part.

Error log:
```
$ ./herwig-bootstrap -j 4 $PWD --herwig-hg --thepeg-hg --thepeg-version="default" --herwig-version="default"
/usr/bin/env: 'python': No such file or directory
```
Solution:
```
$ ln -s $(which python3) $PWD/python
$ export PATH=$PWD:$PATH
```

Error log:
```
Python 3 install needs cython to rebuild lhapdf, yoda and
   rivet python interfaces
```
Solution:
```
$ pip install --user cython
$ export PATH=$HOME/.local/bin:$PATH
```

Error log:
```
hg clone https://phab.hepforge.org/source/thepeghg/ ThePEG-default
Traceback (most recent call last):
  File "./herwig-bootstrap", line 1001, in <module>
    checkout(src_dir,"ThePEG",opts.thepeg_ver,opts.thepeg_repo,branch)
  File "./herwig-bootstrap", line 508, in checkout
    check_call(["hg","clone",repo,directory])
  File "./herwig-bootstrap", line 498, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 359, in check_call
    retcode = call(*popenargs, **kwargs)
  File "/usr/lib/python3.8/subprocess.py", line 340, in call
    with Popen(*popenargs, **kwargs) as p:
  File "/usr/lib/python3.8/subprocess.py", line 858, in __init__
    self._execute_child(args, executable, preexec_fn, close_fds,
  File "/usr/lib/python3.8/subprocess.py", line 1704, in _execute_child
    raise child_exception_type(errno_num, err_msg, err_filename)
FileNotFoundError: [Errno 2] No such file or directory: 'hg'
```
Solution:
```
pip install --user mercurial
```

Error log:
```
autoreconf -vi
autoreconf: Entering directory `.'
autoreconf: configure.ac: not using Gettext
autoreconf: running: aclocal -I m4
configure.ac:3: error: Autoconf version 2.71 or higher is required
configure.ac:3: the top level
autom4te: /usr/bin/m4 failed with exit status: 63
aclocal: error: echo failed with exit status: 63
autoreconf: aclocal failed with exit status: 63
Traceback (most recent call last):
  File "./herwig-bootstrap", line 1001, in <module>
    checkout(src_dir,"ThePEG",opts.thepeg_ver,opts.thepeg_repo,branch)
  File "./herwig-bootstrap", line 519, in checkout
    check_call(["autoreconf","-vi"])
  File "./herwig-bootstrap", line 498, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 364, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['autoreconf', '-vi']' returned non-zero exit status 63.

```
Solution:
```
cd ~/.local/src/
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
tar -xzf autoconf-2.71.tar.gz
cd autoconf-2.71
./configure --prefix=$HOME/.local
make
make install
rm -rf ~/.local/src/autoreconf*
```

Error log:
```
autoreconf: running: libtoolize --copy
Can't exec "libtoolize": No such file or directory at /home/joonblee/.local/share/autoconf/Autom4te/FileUtils.pm line 293.
autoreconf: error: libtoolize failed with exit status: 2
Traceback (most recent call last):
  File "./herwig-bootstrap", line 1001, in <module>
    checkout(src_dir,"ThePEG",opts.thepeg_ver,opts.thepeg_repo,branch)
  File "./herwig-bootstrap", line 519, in checkout
    check_call(["autoreconf","-vi"])
  File "./herwig-bootstrap", line 498, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 364, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['autoreconf', '-vi']' returned non-zero exit status 2.
```
Solution:
```
cd $WD/.local/src/
wget http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
tar -xzf libtool-2.4.6.tar.gz
cd libtool-2.4.6
./configure --prefix=$HOME/.local
make
make install
```
I'm not sure but you may need to manually set the `LIBTOOL` environment as 
```
$ export LIBTOOL=/home/joonblee/.local/bin/libtool
$ export LIBTOOLIZE=/home/joonblee/.local/bin/libtoolize
$ export ACLOCAL_PATH=/home/joonblee/.local/share/aclocal:$ACLOCAL_PATH
```

Error log:
```
Extract MG5_aMC_v3.5.1.tar.gz
mv /data6/Users/joonblee/herwig74pre/src/MG5_aMC_v3_5_1/data6/Users/joonblee/herwig74pre/opt/MG5_aMC_v3_5_1
/data6/Users/joonblee/herwig74pre/opt/MG5_aMC_v3_5_1/bin/mg5_aMC proc.dat
madgraph requires the six module. The easiest way to install it is to run "python -m pip install six --user"
in case of problem with pip, you can download the file at https://pypi.org/project/six/ . It has a single python file that you just need to put inside a directory of your $PYTHONPATH environment variable.
python2 /data6/Users/joonblee/herwig74pre/opt/MG5_aMC_v3_5_1/bin/mg5_aMC proc.dat
Traceback (most recent call last):
  File "./herwig-bootstrap", line 1019, in runMadgraph
    check_call([mg_exe,'proc.dat'])
  File "./herwig-bootstrap", line 498, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 364, in check_call
    raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/data6/Users/joonblee/herwig74pre/opt/MG5_aMC_v3_5_1/bin/mg5_aMC', 'proc.dat']' returned non-zero exit status 1.

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "./herwig-bootstrap", line 1078, in <module>
    runMadgraph(mg_initial_run)
  File "./herwig-bootstrap", line 1021, in runMadgraph
    check_call(['python2',mg_exe,'proc.dat'])
  File "./herwig-bootstrap", line 498, in check_call
    subprocess.check_call(arglist)
  File "/usr/lib/python3.8/subprocess.py", line 359, in check_call
    retcode = call(*popenargs, **kwargs)
  File "/usr/lib/python3.8/subprocess.py", line 340, in call
    with Popen(*popenargs, **kwargs) as p:
  File "/usr/lib/python3.8/subprocess.py", line 858, in __init__
    self._execute_child(args, executable, preexec_fn, close_fds,
  File "/usr/lib/python3.8/subprocess.py", line 1704, in _execute_child
    raise child_exception_type(errno_num, err_msg, err_filename)
FileNotFoundError: [Errno 2] No such file or directory: 'python2'
```
Solution:
One should install python2 with pyenv. First, install `pyenv` as follow:
```
cd ~/.local/src
curl -L -o pyenv.tar.gz https://github.com/pyenv/pyenv/archive/refs/heads/master.tar.gz
tar -xzf pyenv.tar.gz
mkdir -p ~/.pyenv
mv pyenv-master/* ~/.pyenv/
git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```
After that install `bzip`.
```
cd ~/.local/src
wget https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
tar -xzf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
make -f Makefile-libbz2_so
make install PREFIX=$HOME/.local
export LDFLAGS="-L$HOME/.local/lib"
export CPPFLAGS="-I$HOME/.local/include"
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig"
```
Finally one can install `python 2.7.18` with
```
# pyenv uninstall 2.7.18 # uninstall previous installed python 2.7.18.
pyenv install 2.7.18
pyenv install 3.8.10
pyenv global 3.8.10 2.7.18
pip3 install --user six
```


## Notes: Sigularity (old, failed)
```
$ singularity shell /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-ubuntu-20.04:latest
$ bash % to use nominal bash scripts
```
To use `.bashrc` only for this singularity, I set `~/.singularity-env` as
```
export SINGULARITY_SHELLRCFILE="$HOME/.bashrc.singularity"
```
and create `~/.bashrc.singularity`


In the singularity, I should have installed libtool, 
```
$ wget https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
$ tar -xzvf libtool-2.4.6.tar.gz
$ ./configure --prefix=/home/joonblee/ubuntu20.04/local/libtool
$ make
$ make install
$ export PATH=$PATH:$HOME/ubuntu20.04/local/libtool/bin

$ wget https://ftp.gnu.org/gnu/emacs/emacs-28.2.tar.gz
$ tar -xvf emacs-28.2.tar.gz
$ ./configure --prefix=/home/joonblee/ubuntu20.04/local/emacs --with-x-toolkit=no --with-gnutls=ifavailable
$ make
$ make install
$ export PATH=$PATH:$HOME/ubuntu20.04/local/emacs/bin


$ wget https://www.openssl.org/source/openssl-1.1.1t.tar.gz
$ tar -xvf openssl-1.1.1t.tar.gz
$ cd openssl-1.1.1t
$ ./config --prefix=/home/joonblee/ubuntu20.04/local/openssl
$ make
$ make install
$ export LD_LIBRARY_PATH=/home/joonblee/ubuntu20.04/local/openssl/lib:$LD_LIBRARY_PATH
```

The command line `pip3 install python-is-python --prefix=/my/own/dir` fails.
Therefore,
```
$ ln -s $(which python3) $HOME/ubuntu20.04/local/bin/python
$ export PATH=$HOME/local/bin:$PATH
 
 
$ wget --no-check-certificate https://www.mercurial-scm.org/release/mercurial-6.3.2.tar.gz
$ tar -xvf mercurial-6.3.2.tar.gz
$ cd mercurial-6.3.2
$ make local PREFIX=/home/joonblee/ubuntu20.04/local/mercurial
$ make install PREFIX=$HOME/ubuntu20.04/local/mercurial
$ ~/ubuntu20.04/local/mercurial/bin/hg 
$ (I install docutils, $ pip3 install docutils.)
$ export PATH="$HOME/ubuntu20.04/local/mercurial/bin:$PATH"

$ pip3 install --user cython sympy scipy six


wget --no-check-certificate https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.tar.bz2
wget --no-check-certificate https://ftpmirror.gnu.org/gnu/gsl/gsl-2.6.tar.gz
wget --no-check-certificate https://fastjet.hepforge.org/contrib/downloads/fjcontrib-1.042.tar.gz
wget --no-check-certificate https://lhapdf.hepforge.org/downloads/LHAPDF-6.3.0.tar.gz 
wget --no-check-certificate https://yoda.hepforge.org/downloads//YODA-1.8.1.tar.bz2
wget --no-check-certificate https://rivet.hepforge.org/downloads//Rivet-3.1.0.tar.bz2
wget --no-check-certificate https://thepeg.hepforge.org/downloads/ThePEG-2.2.3.tar.bz2
wget --no-check-certificate  http://madgraph.physics.illinois.edu/Downloads//MG5_aMC_v2.8.1.tar.gz
wget --no-check-certificate https://bitbucket.org/njet/njet/downloads/njet-2.0.0.tar.gz
wget --no-check-certificate  https://openloops.hepforge.org/downloads/OpenLoops-2.1.1.tar.gz
wget --no-check-certificate  https://www.itp.kit.edu/vbfnlo/archive/vbfnlo-3.0.0beta5.tgz
wget --no-check-certificate  https://pythia.org/download/pythia82/pythia8240.tgz
wget --no-check-certificate  https://evtgen.hepforge.org/downloads/EvtGen-01.07.00.tar.gz
wget --no-check-certificate  https://herwig.hepforge.org/downloads//Herwig-7.2.3.tar.bz2


736  export PATH="$HOME/ubuntu20.04/local/miniconda3/bin:$PATH"

  746  conda_activate 
  748  conda create --name lhapdf

  749  conda activate lhapdf

  754  conda install -c conda-forge lhapdf
```

## conda
```
cdwd
bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/WD/miniconda3/
cd miniconda3/
source ~/.bashrc
conda info --evns
conda create --name hw7-py2
conda activate hw7-py2
conda create -n hw-py2 python=2
conda activate hw-py2
```

# 7. About Mercurial

Below page gives a nice tutorial for the mercurial and hg
http://btsweet.blogspot.com/2013/12/hg-1-mecurial-basics.html

Additional useful command lines:
```
$ hg status
$ hg diff -b > patch.diff
```










