# 1. How to install Hw7
Herwig works under Ubuntu 20.X with 
```
$ sudo apt -y install gcc g++ gfortran automake autoconf libtool tar make emacs wget openssl mercurial git
$ sudo apt-get -y install libssl-dev # instead of openssl-devel
$ sudo apt-get -y install python3-pip
$ sudo pip3 install cython sympy scipy  six
```

### Some errors
[1] After re-installing Ubuntu, I've got a following errors: 
```
/usr/bin/env: %%% ‘python’: No such file or directory.
```
This can be solved by $ sudo apt install python-is-python3)

[2] In TH's desktop, there is no gengetopt so do `$ sudo apt-get install -y gengetopt`, then 
```
$ chmod +x herwig-bootstrap
$ ./herwig-bootstrap -j 4 ./
```
should work.

Use `--without-PROGRAM` option when some programs are not installed due to the network error, e.g. `--without-vbfnlo`.
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

### Special note
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

### [1] Error during 'make'
```
g++ -std=c++11 -fPIC -I/home/joonblee/WD/Herwig/./include -I/home/joonblee/WD/Herwig/.//include -I/home/joonblee/WD/Herwig/.//include -Wall -Wextra -pedantic -O2 -DBOOST_UBLAS_NDEBUG -c FRModel.cc -o FRModel.o
g++ -std=c++11 -fPIC -I/home/joonblee/WD/Herwig/./include -I/home/joonblee/WD/Herwig/.//include -I/home/joonblee/WD/Herwig/.//include -Wall -Wextra -pedantic -O2 -DBOOST_UBLAS_NDEBUG -c FRModel.cc -o FRModel.o
g++: internal compiler error: Segmentation fault signal terminated program cc1plus
Please submit a full bug report,
with preprocessed source if appropriate.
See <file:///usr/share/doc/gcc-9/README.Bugs> for instructions.
make: *** [Makefile:37: FRModel.o] Error 4
```


# 2. How to run validation code
How to run Aidin's validation code, in ssh://vcs@phab.hepforge.org/diffusion/548/herwig-bsm-notes/?
(Up-to-date validation repo: https://github.com/joonblee/hw7_validation/tree/main)


## Issue-1
To run Aidin's validation code(ZH), I update MG5 version to 3.3.2 as follows:
```
$ rm -rf opt/MG5_*
$ rm src/herwig_bootstrap_madgraph_done
$ ./herwig-bootstrap -j 4 ./ --madgraph-version=3.3.2
```

## Issue-2
When I run the validation code and run MG5, I've got an error which cannot find NNPDF23_ls_as_0130_qed.

### method 1: I thus install it seperately.
```
$ source bin/activate 
$ lhapdf install NNPDF23_lo_as_0130_qed
```

### method 2: install lhapdf6 in madgraph seperately. -> launch madgraph and do "install lhapdf6".

### method 3: Use LHAPDF6 in herwig7, which is installed by the bootstrap code. 
set lhapdf /PATH/TO/lhapdf-config
in MG5 UI.

Note method 1 does not work in some cases.
Use method 2 or 3.

## How to run?
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



# 3. How to run rivet
Before running rivet, we should install latex and image magic.
```
$ sudo apt install -y texlive-full % I first install texlive-latex-base as '$ sudo apt install texlive-latex-base', which only installs a minimal latex. However it doesn't work properly. '$ make-plots test.dat' doesn't make any plot. (All types of image files such as ps, eps, pdf, png files are not generated.)
$ sudo apt install imagemagick-6.q16
```
Finally we can make some plots with Rivet using below commands:
```
$ rivet-mkhtml FO.yoda
```



# 5. How to push updates on my local repo to the remote repo?

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


# 6. BSM model

Install 2HDMtII_NLO file from https://feynrules.irmp.ucl.ac.be/raw-attachment/wiki/2HDM/2HDMtII_NLO.tar.gz
```
$ cd /go/to/test/directory
$ tar xzf 2HDMtII_NLO.tar.gz
$ ufo2herwig 2HDMII_NLO --convert
$ make
```

*** If there is any other `*.cc` files in current directory without `FRModel.cc` then the `make` (based on `Makefile`) compile all `*.cc` files and make some troubles. Troubleshouting: modify Makefile `*.cc` -> `FRModel*.cc`.
*** When you successfully run `ufo2herwig` but get some errors after `make` such as `cannot find FRModel.so` (which is nominally due to another `*.cc` files in the directory), you should erase the model directory (i.e. 2HDMtII_NLO in this case) because it might already include some errors inside


ufo2herwig /address/to/ufo --allow-fcnc




# Optionals

# 1. Mercurial
Below page gives a nice tutorial for the mercurial and hg
http://btsweet.blogspot.com/2013/12/hg-1-mecurial-basics.html

Additional useful command lines:
```
$ hg status
$ hg diff -b > patch.diff
```

# 2. Crash between ThePEG and herwigbsm (after Jan 2023)
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





# 3. conda
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



# 4. sigularity
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















