// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/FastJets.hh"
#include <iostream>
#include <fstream>
/// @todo Include more projections as required, e.g. ChargedFinalState, FastJets, ZFinder...

double norm = 1.;
int zp_pid = 9900032;

namespace Rivet {

  class RAnalysis : public Analysis {
  public:

    /// Constructor
    RAnalysis()
      : Analysis("RAnalysis")
    {    }

    /// @name Analysis methods
    //@{

    /// Book histograms and initialise projections before the run
    void init() {
      // Projections
      declare(FinalState(), "FS");
      declare(FastJets(FinalState(), FastJets::ANTIKT, 0.4), "Jets");

      book(_n_evt,    "n_evt",   10,0,10);
      book(_h_pt_jet, "h_pt_jet",   40,0.,200.0);
      book(_h_pt_mu,  "h_pt_mu",   100,0.,100.);
      book(_h_pt_lmu, "h_pt_lmu",   100,0.,100.);
      book(_h_pt_smu, "h_pt_smu",   100,0.,100.);
      book(_h_pt_branch, "h_pt_branch",   40,0.,200.);
      book(_h_dR_jz,  "h_dR_jz", 40, 0., 4.);
      book(_h_dR_jmu, "h_dR_jmu", 40, 0., 4.);
      book(_h_dR_jlmu, "h_dR_jlmu", 40, 0., 4.);
      book(_h_dR_jsmu, "h_dR_jsmu", 40, 0., 4.);
      book(_h_invm1,   "h_invm1",  40,0.,20.);

      book(_n_outs,    "n_outs",   5,0,5);
      book(_h_pt_q, "h_pt_q",   40,0.,200.);
      book(_h_dR_qz,  "h_dR_qz", 40, 0., 4.);
      book(_h_dR_qz_FSR,  "h_dR_qz_FSR", 40, 0., 4.);
      book(_h_dR_qz_ISR,  "h_dR_qz_ISR", 40, 0., 4.);
      book(_h_dR_qmu, "h_dR_qmu", 40, 0., 4.);
      book(_h_dR_qlmu, "h_dR_qlmu", 40, 0., 4.);
      book(_h_dR_qsmu, "h_dR_qsmu", 40, 0., 4.);

      book(_h_pT,  "h_pT",  100,0.,400.0);
      book(_h_z,   "h_z",   100,0.,1.);

      book(_h_dR_dimuonz, "h_dR_dimuonz", 40, 0., 4.);
      book(_h_ptratio_dimuonOverz, "h_ptratio_dimuonOverz", 200, 0., 2.);
    }

    /// Perform the per-event analysis
    void analyze(const Event& event) {
      //setup analysis

      const FinalState& fs = applyProjection<FinalState>(event, "FS");
      const FastJets& alljets = applyProjection<FastJets>(event, "Jets");
      const Jets& ptjets = alljets.jetsByPt(20.*GeV);

      const Particles& allptc = event.allParticles();




      _n_evt->fill(1);

      // Select dimuon candidates
      Particle mu1, mu2, lmu, smu; bool b_mu1 = false; bool b_mu2 = false;
      for(const Particle& p : fs.particles()) {
        if(p.pt() > 10.&&p.abseta()<2.4) {
          if(p.pid()==13&&!b_mu1) {
            mu1=p; b_mu1 = true;
          }
          else if(p.pid()==-13&&!b_mu2) {
            mu2=p; b_mu2 = true; 
          }
        }
        if( b_mu1 && b_mu2 ) break;
      }

      if( !(b_mu1 && b_mu2) ) vetoEvent;
      _n_evt->fill(2);

      // if( !(mu1.pt() > 5. && mu1.abseta() < 3. && mu2.pt() > 5. && mu2.abseta() < 3.) ) vetoEvent;
      _n_evt->fill(3);

      if(mu1.pt()>mu2.pt()) { lmu=mu1; smu=mu2; }
      else { lmu=mu2; smu=mu1; }

      const FourMomentum dimuon = mu1.momentum() + mu2.momentum();
      if( 3. < dimuon.mass() && dimuon.mass() < 3.2 ) vetoEvent;
      _n_evt->fill(4);


      // Select a Z' boson
      Particle zp; int Nzp = 0;
      const string sampleTag = getOption("sample", "");  // getOption("sample", defaultValue)
      if (sampleTag == "FO" || sampleTag == "RS") {
        //MSG_INFO("Detected FO/RS sample from plugin option.");
        for(const Particle& p : allptc) {
          if(p.pid()==zp_pid && !p.hasChildWith(Cuts::abspid==zp_pid)) {
            zp = p; Nzp++;
          }
        }
        if( Nzp != 1 ) vetoEvent; // There should exist only one Z' boson


        _n_evt->fill(5);
        _h_dR_dimuonz->fill(deltaR(dimuon, zp.momentum()));

        _h_ptratio_dimuonOverz->fill(dimuon.pt()/zp.pt());
        if( deltaR(dimuon, zp.momentum()) > 0.2 || fabs(1-dimuon.pt()/zp.pt()) > 0.3 )
          _n_evt->fill(6);
          // cout<<" NOTE: This event has dR > 0.2 or ptratio > 0.3."<<endl;
          // cout<<" - dimuon: "<<dimuon<<endl;
      }

      // Select hard quarks
      Particles outs, legs;  Particle test;
      for(const auto& p : allptc) {
        auto gp = p.genParticle();
        if( !gp ) continue;
        if( gp->status() != 11 ) continue;
        auto vtx = gp->production_vertex();
        if( !vtx ) continue;
        if( vtx->particles_in().size()==2 && vtx->particles_out().size()>1 ) {
          if( p.abspid()<7 || p.pid()==21 ) { 
            outs.push_back(p);
            test = p;
          }
        }
        if( outs.size() == 2 ) break;
      }


      _n_outs->fill( outs.size() );
      if( outs.size() == 0 || outs.size() > 2 ) {
        cout<<endl<<" *** ERROR *** No hard state quark or too many hard state quarks."<<endl;
        cout<<" #(hard state quark) = "<<outs.size()<<endl<<endl;
        vetoEvent;
      }
      _n_evt->fill(7);






/*
// REMOVE THIS PART LATER //
cout<<endl<<endl<<endl;
cout<<"-------------------------------------------"<<endl;
cout<<"[EVENT DESCRIPTION]"<<endl<<endl;
print_particle(mu1);
print_particle(mu2);
print_particle(zp);

cout<<endl;
cout<<"[Hard state particle history]"<<endl<<endl;
for(const auto& p : outs) {
  cout<<"1st ptc: ";
  print_particle(p);
  cout<<endl;
  Particle cand = p;
  while( cand.children().size()>0 ) {
    for( const auto& pp : cand.children() ) {
      print_particle(pp);      
    }
    cand = (cand.children())[0];
    cout<<endl;
  }
}
/////////////////////////////
*/






      // FSR?
      bool isFSR = false;
      if( sampleTag == "RS" ) {
        for(const auto& p : outs) {
          if( p.pid() == 21 ) continue;
          Particle cand = p;
          while( cand.children().size()>0 && !isFSR ) {
            if( cand.children().size() == 1 ) {
              if( (cand.children())[0].pid() == p.pid() )
                cand = (cand.children())[0];
              else break;
            }
            else if( cand.children().size() == 2 ) {
              Particle p0 = (cand.children())[0];
              Particle p1 = (cand.children())[1];
              if( p0.pid() == p.pid() ) {
                if( p1.pid() == zp_pid ) isFSR = true;
                else if( 20 < p1.pid() && p1.pid() < 26 ) cand = p0;
                else break;
              }
              else if( p1.pid() == p.pid() ) { 
                if( p0.pid() == zp_pid ) isFSR = true;
                else if( 20 < p0.pid() && p0.pid() < 26 ) cand = p1;
                else break;
              }
              else break;
            }
            else break;
          }
          if( isFSR ) break;
        }
      }

      // Find final copy of the quark
      if( isFSR ) {
//cout<<" [NOTICE] isFSR = 1"<<endl;
        if( zp.parents().size() == 1 ) {
          Particle cand = (zp.parents())[0];
          while( cand.children().size() == 1 ) { // The parent is Z' itself
            cand = (cand.parents())[0];
          }
          if( (cand.children())[0].pid() == zp_pid ) cand = (cand.children())[1];
          else cand = (cand.children())[0];
          while( cand.children().size() > 0 ) {
            if( cand.children().size() == 1 ) {
              if( (cand.children())[0].pid() == cand.pid() )
                cand = (cand.children())[0];
              else {
                legs.push_back(cand);
                break;
              }
            }
            else {
              legs.push_back(cand);
              break;
            }
          }
          if( cand.children().size() == 0 ) legs.push_back(cand); // This line is for GEN analysis. You can erase this life for jet analysis safely
        }
        else { // For validation. Impossible radiation.
          cout<<" *** ERROR *** Z' has two parents."<<endl;
          vetoEvent;
        }

        Particle cand; Particle p = zp;
        while( p.parents().size() == 1 ) {
          p = (p.parents())[0];
          if( p.genParticle() == outs[0].genParticle() ) {
            cand = outs[1];
            break;
          }
          else if( p.genParticle() == outs[1].genParticle() ) {
            cand = outs[0];
            break;
          }
        }
        if( cand.genParticle() == nullptr ) {
          cout<<" *** ERROR *** Wrong hard state quraks."<<endl;
          vetoEvent;
        }
        while( cand.children().size()>0 ) {
          if( cand.children().size() == 1 ) {
            if( (cand.children())[0].pid() == cand.pid() )
              cand = (cand.children())[0];
            else {
              legs.push_back(cand);
              break;
            }
          }
          else {
            legs.push_back(cand);
            break;
          }
        }
        if( cand.children().size() == 0 ) legs.push_back(cand); // This line is for GEN analysis. You can erase this life for jet analysis safely
      }
      else { // FO, RS(ISR), backgrounds, or something else
//cout<<" [NOTICE] isFSR = 0"<<endl<<endl;
        for(const auto& p : outs) {
          Particle cand = p;
          while( cand.children().size()>0 ) {
            if( cand.children().size() == 1 ) {
              if( p.pid() == (cand.children())[0].pid() )
                cand = (cand.children())[0];
              else {
                legs.push_back(cand);
                break; // Normally child's PID == 81, which means hadronisation (need to be checked)
              }
            }
            else if( cand.children().size() == 2 ) {
              Particle p0 = (cand.children())[0];
              Particle p1 = (cand.children())[1];
              if( ( cand.pid() == 21 && p0.abspid() == p1.abspid() ) // g -> qqbar or g -> gg
                  || ( p0.pid() == p.pid() && (20 < p1.pid() && p1.pid() < 26) ) // q -> qg
                  || ( p1.pid() == p.pid() && (20 < p0.pid() && p0.pid() < 26) ) // q -> gq
                )
                legs.push_back(cand); 
              else { // For validation. One can remove this part in safe
                cout<<endl<<" *** ERROR *** Something strange is radiated."<<endl;
                cout<<"parent: "; print_particle(cand);
                cout<<"p0: "; print_particle(p0);
                cout<<"p1: "; print_particle(p1);
                vetoEvent;
              }
              break;
            }
            else {
              legs.push_back(cand);
              break;
            }
          }
          if( cand.children().size() == 0 ) legs.push_back(cand); // This line is for GEN analysis. You can erase this life for jet analysis safely
        }
      }

      if( legs.size() != 2 ) { // legs.size() == 0 || legs.size() > 2 
        cout<<" *** ERROR *** There is no good hard state quark or there are too many quark candidates.."<<endl;
        cout<<" - hard particles - "<<endl;
        for(const auto& p : outs) {
          print_particle(p);
        }
        cout<<" - final particles - "<<endl;
        for(const auto& p : legs) {
          print_particle(p);
        }
        vetoEvent;
      }



/*
/////////////////////////////
cout<<"[Selected partons]"<<endl<<endl;
if( legs.size() > 0 ) {
  for(const auto& leg: legs) {
    print_particle(leg);
  }
}
else cout<<"NO legs"<<endl;
/////////////////////////////
*/
















      // Apply pt cut on the fianl quark candidate (erase this part later)
      for(const auto& leg : legs) {
        if( leg.abseta() > 3. || leg.pt() < 20. ) {
          //cout<<"*** VETO EVNET due to parton kenematic cuts ***"<<endl;
          vetoEvent;
        }
      }
      _n_evt->fill(8);

      double dr = 999.;
      Particle partner;

      
      //double pT, zq;
      if( legs.size() == 1 ) {
        partner = legs[0];
      }
      else {
        double pT2[2], z[2];
        for(int i=0; i<legs.size(); i++) {
          Particle leg = legs[i];
          double m1 = leg.momentum().mass();
          double m2 = dimuon.mass();
          FourMomentum p = leg.momentum()+dimuon;
          double absp3 = p.p();
          FourMomentum n;
          n.setT(1); n.setX(-p.x()/absp3); n.setY(-p.y()/absp3); n.setZ(-p.z()/absp3);
          z[i] = leg.momentum()*n/(p*n);
          pT2[i] = z[i]*(1.-z[i])*p.invariant()-(1.-z[i])*sqr(m1)-z[i]*sqr(m2);
        }

        if(pT2[0]>=0. && (pT2[0]<pT2[1] || pT2[1]<0.)) {
          partner = legs[0]; //recoil = leg[1];
          //pT = sqrt(pT2[0]);
          //zq = z[0];
        }
        else {
          partner = legs[1]; //recoil = leg[0];
          //pT = sqrt(pT2[1]);
          //zq = z[1];
        }
      }
      /*
      else {
        if( deltaR(dimuon, legs[0].momentum()) < deltaR(dimuon, legs[1].momentum()) ) partner = legs[0];
        else partner = legs[1];
      }
      */

      _h_pt_q->fill(partner.pt());
      _h_dR_qz->fill(deltaR(partner.momentum(), dimuon));
      if(sampleTag == "RS") {
        if(isFSR) _h_dR_qz_FSR->fill(deltaR(partner.momentum(), dimuon));
        else _h_dR_qz_ISR->fill(deltaR(partner.momentum(), dimuon));
      }
      _h_dR_qmu->fill(deltaR(partner.momentum(),lmu.momentum()));
      _h_dR_qmu->fill(deltaR(partner.momentum(),smu.momentum()));
      _h_dR_qlmu->fill(deltaR(partner.momentum(),lmu.momentum()));
      _h_dR_qsmu->fill(deltaR(partner.momentum(),smu.momentum()));
      //_h_pT->fill(pT);
      //_h_zq->fill(zq);

      Jets jets; Jet branch;
      dr = 999.;
      for(const auto& j: ptjets) {
        if( !(j.abseta() < 2.4 && j.pt() > 30.) ) continue;
        _h_pt_jet->fill(j.pt());
        jets.push_back(j);
        double dr_ = deltaR(j.momentum(), dimuon);
        if( dr_ < dr ) {
          dr = dr_;
          branch = j;
        }
        break;
      }
      if( dr > 900. ) vetoEvent;
      _n_evt->fill(9);


/*
/////////////////////////////
cout<<endl;
cout<<"[EVENT INFO]"<<endl<<endl;
cout<<" - partner quark: ";
print_particle(partner);
if(legs.size()>0) cout<<" dR(p0, Z') = "<<deltaR(legs[0].momentum(), dimuon)<<endl;
if(legs.size()>1) cout<<" dR(p1, Z') = "<<deltaR(legs[1].momentum(), dimuon)<<endl;
cout<<" dR(partner, Z') = "<<deltaR(partner.momentum(), dimuon)<<endl;
     

cout<<" dR(j, Z') = "<<deltaR(branch, dimuon)<<endl;

cout<<" j       = ";
print_particle(branch);
cout<<" partner = ";
print_particle(partner);
////////////////////////////////
*/


      _h_pt_mu->fill(mu1.pt());
      _h_pt_mu->fill(mu2.pt());
      _h_pt_branch->fill(branch.pt());
      _h_pt_lmu->fill(lmu.pt());
      _h_pt_smu->fill(smu.pt());
      _h_dR_jz->fill(dr);
      _h_dR_jmu->fill(deltaR(branch.momentum(),lmu.momentum()));
      _h_dR_jmu->fill(deltaR(branch.momentum(),smu.momentum()));
      _h_dR_jlmu->fill(deltaR(branch.momentum(),lmu.momentum()));
      _h_dR_jsmu->fill(deltaR(branch.momentum(),smu.momentum()));
      _h_invm1->fill((mu1.momentum()+mu2.momentum()).mass());
    }

    /// Normalise histograms etc., after the run
    void finalize() {
      const string sampleTag = getOption("sample", "");  // getOption("sample", defaultValue)
      if (sampleTag == "RS") {
        //MSG_INFO("Detected RS sample from plugin option.");
        norm = (double)numEvents() / 20000.; // Z' radiation rate
        norm *= 0.01; // coupling
        norm *= 0.0106103 / 0.0644342; // BR for Z'->mumu
        norm *= 2.552/10.208; // HepMC xsec bug
      }
      else if (sampleTag == "QCD") {
        //MSG_INFO("Detected QCD sample from plugin option.");
        norm = 1.; 202070.1 / 6308848.; // n_evt based weight
        // 4453.5322999999989 / 19349980.0; // sig(FO, hepmc)/sig(QCD, mg) sig(QCD, hepmc) = 1.399e6
      }

      double weight = crossSection()/sumOfWeights()/femtobarn * norm;

      scale(_n_evt, weight);
      scale(_h_pt_jet, weight);
      scale(_h_pt_mu, weight);
      scale(_h_pt_branch, weight);
      scale(_h_pt_lmu, weight);
      scale(_h_pt_smu, weight);
      scale(_h_dR_jz, weight);
      scale(_h_dR_jmu, weight);
      scale(_h_dR_jlmu, weight);
      scale(_h_dR_jsmu, weight);

      scale(_h_invm1, weight);

      scale(_n_outs, weight);
      scale(_h_pt_q, weight);
      scale(_h_dR_qz, weight);
      scale(_h_dR_qz_FSR, weight);
      scale(_h_dR_qz_ISR, weight);
      scale(_h_dR_qmu, weight);
      scale(_h_dR_qlmu, weight);
      scale(_h_dR_qsmu, weight);

      scale(_h_pT, weight);
      scale(_h_z, weight);

      scale(_h_dR_dimuonz, weight);
      scale(_h_ptratio_dimuonOverz, weight);


      // data file
      std::ofstream file;
      string fname = "RAnalysis.dat";
      file.open(fname.c_str());
      file << "PLOT\n";
      file.close();
    }

    //@}


  private:

    // Data members like post-cuts event weight counters go here


    /// @name Histograms
    //@{
    Histo1DPtr _n_evt;
    Histo1DPtr _h_pt_jet;
    Histo1DPtr _h_pt_mu;
    Histo1DPtr _h_pt_branch;
    Histo1DPtr _h_pt_lmu;
    Histo1DPtr _h_pt_smu;
    Histo1DPtr _h_dR_jz;
    Histo1DPtr _h_dR_jmu;
    Histo1DPtr _h_dR_jlmu;
    Histo1DPtr _h_dR_jsmu;
    Histo1DPtr _h_invm1;
    Histo1DPtr _n_outs;
    Histo1DPtr _h_pt_q;
    Histo1DPtr _h_dR_qz;
    Histo1DPtr _h_dR_qz_FSR;
    Histo1DPtr _h_dR_qz_ISR;
    Histo1DPtr _h_dR_qmu;
    Histo1DPtr _h_dR_qlmu;
    Histo1DPtr _h_dR_qsmu;
    Histo1DPtr _h_pT;
    Histo1DPtr _h_z;
    Histo1DPtr _h_dR_dimuonz;
    Histo1DPtr _h_ptratio_dimuonOverz;
   //@}


    void print_particle(const Rivet::Particle& p) const {
      std::cout << p.pid()
                << " (" << p.pt()
                << ", " << p.eta()
                << ", " << p.phi() << ")"
                << std::endl;
    }
    void print_particle(const FourMomentum& p) const {
      std::cout << " (" << p.pt()
                << ", " << p.eta()
                << ", " << p.phi() << ")"
                << std::endl;
    }
    void print_particle(const Jet& p) const {
      std::cout << " (" << p.pt()
                << ", " << p.eta()
                << ", " << p.phi() << ")"
                << std::endl;
    }

  };


  // The hook for the plugin system
  //DECLARE_RIVET_PLUGIN(RAnalysis);
  RIVET_DECLARE_PLUGIN(RAnalysis);
}
