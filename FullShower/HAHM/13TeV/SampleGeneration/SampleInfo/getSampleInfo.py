#!/usr/bin/env python3

import os
import subprocess

zps = [5]
ptbin = [65,70,75,80,85,90,100,140,200,9999]
xsec = [8.001E+03,5.577E+03,3.971E+03,2.891E+03,2.135E+03,2.819E+03,3.798E+03,8.858E+02,2.046E+02]

basepath = "/gv0/Users/taehee/HerwigSample/samples/RunIISummer20UL"
eras = ["16", "16APV", "17", "18"]
infodirs = ["2016preVFP","2016postVFP","2017","2018"]

for i in range(len(eras)):
    era = eras[i]
    for zpmass in zps:
        for j in range(len(ptbin)-1):

            ptlow = ptbin[j]
            pthigh = ptbin[j+1]
            infodir = infodirs[i]
            filepath = f"{basepath}{era}/MZp-{zpmass}/Pt-{ptlow}To{pthigh}*/MiniAOD*root"
            infofile = f"Zp_M-{zpmass}_Pt-{ptlow}to{pthigh}_hw7.txt"

            # info ForSNU
            dirForSNU = f"{infodir}/Sample/ForSNU"
            os.makedirs(dirForSNU, exist_ok=True)
            filelist = subprocess.check_output(f"ls {filepath}", shell=True).decode("utf-8").strip()
            pathForSNU = os.path.join(dirForSNU, infofile)
            with open(pathForSNU,"w") as f:
                f.write(filelist+"\n")

            # info Common
            dirCommon = f"{infodir}/Sample/CommonSampleInfo"
            os.makedirs(dirCommon, exist_ok=True)
            pathCommon = os.path.join(dirCommon, infofile)
            alias = f"Zp_M-{zpmass}_Pt-{ptlow}to{pthigh}_hw7"
            nFile = int(subprocess.check_output(f"ls {filepath} | wc -l", shell=True).decode("utf-8").strip())
            nEvent = nFile*100000
            with open(pathCommon,"w") as f:
                f.write("# alias PD xsec nmc sumsign sumw\n")
                f.write(f"{alias}\t{alias}\t{xsec[i]}\t{nEvent}\t{nEvent}")
