// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/FastJets.hh"
#include <iostream>
#include <fstream>
/// @todo Include more projections as required, e.g. ChargedFinalState, FastJets, ZFinder...



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
      //FinalState fs;
      //declare(fs, "FS");
      //FastJets jets(fs, FastJets::ANTIKT, 0.4);
      //declare(jets, "Jets");

      declare(FinalState(), "FS");
      declare(FastJets(FinalState(), FastJets::ANTIKT, 0.4), "Jets");

      book(_n_evt, "N_evt", 5,0,5);
      book(_n_njet, "n_njet", 5,0.,5.);

      book(_h_Mzp,  "h_Mzp",  100,  0., 10.);
      book(_h_ptzp,  "h_ptzp",  100,  0., 400.0);
      book(_h_etazp, "h_etazp",  60, -3.,    3.);

      book(_h_ptmu,   "h_pt(mu)",   100,  0., 500.0);
      book(_h_ptmu1,   "h_pt(mu1)",   100,  0., 500.0);
      book(_h_ptmu2,   "h_pt(mu2)",   100,  0., 500.0);

      book(_h_etamu,  "h_eta(mu)",   60, -3.,    3.);

      book(_h_ptj,   "h_pt(j)",   400,  0., 2000.0);
      book(_h_ptj1,  "h_pt(j1)",  400,  0., 2000.0);
      book(_h_ptj2,  "h_pt(j2)",  400,  0., 2000.0);
      book(_h_ptj3,  "h_pt(j3)",  400,  0., 2000.0);

      book(_h_etaj,  "h_eta(j)",   60, -3.,    3.);

      book(_h_dR, "h_dR", 40, 0., 4.);
      book(_h_dR_j_mu1, "h_dR(j,mu1)", 40, 0., 4.);
      book(_h_dR_j_mu2, "h_dR(j,mu2)", 40, 0., 4.);
      book(_h_dR_mu_mu, "h_dR(mu,mu)", 40, 0., 4.);

      book(_h_mhat, "h_mhat", 60, 0., 600.);
      book(_h_ht, "h_ht", 60, 0., 600.);
    }

    bool CheckParent(const Particle& p, int ParentId) {
      for(const Particle& parent : p.parents()) {
        if(parent.pid() == ParentId) return true;
        if(parent.abspid() == 13) return CheckParent(parent,ParentId);
      }
      return false;
    }

    /// Perform the per-event analysis
    void analyze(const Event& event) {
      double wgt = 1.; // event.weight(); -> deprecated. weights are counted automatically.

      //setup analysis
      _n_evt->fill(0,wgt);

      const FinalState& fs = applyProjection<FinalState>(event, "FS");
      const FastJets& alljets = applyProjection<FastJets>(event, "Jets");
      const Jets& ptjets = alljets.jetsByPt(30.*GeV);   

      Particle zp, mup, mum, mu1, mu2;
      Particles muons;
      // find particles
      bool foundMup=0; bool foundMum=0;
      for(const Particle& p : fs.particles()) {
        if( !(p.abspid()==13 && CheckParent(p,1023) && p.pt()>10. && p.abseta()<2.4) ) continue;
        muons.push_back(p);
        _h_ptmu->fill(p.pt(),wgt);
        _h_etamu->fill(p.eta(),wgt);
        if( !foundMum && p.pid()==13 ) {
          mum=p; foundMum=1;
        }
        else if( !foundMup && p.pid()==-13 ) {
          mup=p; foundMup=1;
        }
        if( foundMum && foundMup ) 
          break;
      }
      if(!(foundMum&&foundMup)) vetoEvent;

      if(mum.pt() > mup.pt()) { mu1 = mum; mu2 = mup; }
      else { mu1 = mup; mu2 = mum; }
      _h_ptmu1->fill(mu1.pt(),wgt);
      _h_ptmu2->fill(mu2.pt(),wgt);
      _h_dR_mu_mu->fill(deltaR(mu1.momentum(),mu2.momentum()),wgt);

      zp = Particle(1023, mup.momentum()+mum.momentum());

      _n_evt->fill(1,wgt);
      _h_Mzp->fill(zp.mass(),wgt);
      _h_ptzp->fill(zp.pt(),wgt);
      _h_etazp->fill(zp.eta(),wgt);

      if(ptjets.size()==2) {
        _h_mhat->fill((ptjets[0].momentum()+ptjets[1].momentum()).mass(),wgt);
        _h_ht->fill(ptjets[0].pt()+ptjets[1].pt(),wgt);
      }
      else if(ptjets.size()==3) {
        _h_mhat->fill((ptjets[0].momentum()+ptjets[1].momentum()+ptjets[2].momentum()).mass(),wgt);
        _h_ht->fill(ptjets[0].pt()+ptjets[1].pt()+ptjets[2].pt(),wgt);
      }
      else if(ptjets.size()>3) {
        _h_mhat->fill((ptjets[0].momentum()+ptjets[1].momentum()+ptjets[2].momentum()+ptjets[3].momentum()).mass(),wgt);
        _h_ht->fill(ptjets[0].pt()+ptjets[1].pt()+ptjets[2].pt()+ptjets[3].pt(),wgt);
      }
      
      //Event selection
      bool passEvent = false;
      Jets jets;
      for(const Jet& jet_:ptjets) {
        if( !(jet_.pt() > 30. && jet_.abseta() < 2.4) ) continue;
        Particle lmu, smu;
        double lpt = -999; double spt = -999;
        for(const Particle& mu : muons) {
          if( !(mu.pt()>13.) ) continue;
          if( !(deltaR(mu.momentum(),jet_.momentum())<0.3) ) continue;
          if( mu.pt()>lpt ){
              spt = lpt; lpt = mu.pt();
              smu = lmu; lmu = mu;
          }
          else if( mu.pt()>spt ){
              spt = mu.pt(); smu = mu;
          }
        }
        if( lpt<0 || spt<0 ) continue;
        if( !(lpt>32.) ) continue;
        if( !( (lpt+spt)/jet_.pt() <0.7 ) ) continue;
        jets.push_back(jet_);
        passEvent = true;
      }
      if( !passEvent ) vetoEvent;

      Jet jet; double dr=numeric_limits<double>::max(); unsigned int njet=0;
      for(const Jet& jet_:jets) {
        double dr_ = deltaR(jet_.momentum(),zp.momentum());
        njet++;
        _h_ptj->fill(jet_.pt(),wgt);
        _h_etaj->fill(jet_.eta(),wgt);
        if(njet==1) _h_ptj1->fill(jet_.pt(),wgt);
        if(njet==2) _h_ptj2->fill(jet_.pt(),wgt);
        if(njet==3) _h_ptj3->fill(jet_.pt(),wgt);
        if( dr_ < dr ) {
          jet = jet_;
          dr = dr_;
        }
      }

      if(njet>0) {
        _h_dR->fill(dr,wgt);
        _h_dR_j_mu1->fill(deltaR(jet.momentum(),mu1.momentum()),wgt);
        _h_dR_j_mu2->fill(deltaR(jet.momentum(),mu2.momentum()),wgt);
        _n_evt->fill(2,wgt);
      }
      _n_njet->fill(njet,wgt);
    }

    /// Normalise histograms etc., after the run
    void finalize() {
      double weight = crossSection()/sumOfWeights()/femtobarn;

      scale(_n_evt, weight );
      scale(_n_njet, weight );

      scale(_h_Mzp, weight );
      scale(_h_ptzp, weight );
      scale(_h_etazp, weight );

      scale(_h_ptmu, weight );
      scale(_h_ptmu1, weight );
      scale(_h_ptmu2, weight );
      scale(_h_etamu, weight );

      scale(_h_ptj, weight );
      scale(_h_ptj1, weight );
      scale(_h_ptj2, weight );
      scale(_h_ptj3, weight );
      scale(_h_etaj, weight );

      scale(_h_dR, weight );
      scale(_h_dR_j_mu1, weight );
      scale(_h_dR_j_mu2, weight );
      scale(_h_dR_mu_mu, weight );

      scale(_h_mhat, weight );
      scale(_h_ht, weight );
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
    Histo1DPtr _n_njet;

    Histo1DPtr _h_Mzp;
    Histo1DPtr _h_ptzp;
    Histo1DPtr _h_etazp;

    Histo1DPtr _h_ptmu;
    Histo1DPtr _h_ptmu1;
    Histo1DPtr _h_ptmu2;
    Histo1DPtr _h_etamu;

    Histo1DPtr _h_ptj;
    Histo1DPtr _h_ptj1;
    Histo1DPtr _h_ptj2;
    Histo1DPtr _h_ptj3;
    Histo1DPtr _h_etaj;

    Histo1DPtr _h_dR;
    Histo1DPtr _h_dR_j_mu1;
    Histo1DPtr _h_dR_j_mu2;
    Histo1DPtr _h_dR_mu_mu;

    Histo1DPtr _h_mhat;
    Histo1DPtr _h_ht;
    //@}
  };

  // The hook for the plugin system
  DECLARE_RIVET_PLUGIN(RAnalysis);
}
