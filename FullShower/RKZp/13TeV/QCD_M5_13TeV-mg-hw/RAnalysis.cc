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
      book(_n_rad, "N_rad", 5,0,5);
      book(_h_ptj,   "h_pt(j)",   200,  0., 1000.0);
    }

    /// Perform the per-event analysis
    void analyze(const Event& event) {
      double wgt = 1.; // event.weight(); -> deprecated. weights are counted automatically.

      //setup analysis
      _n_evt->fill(0,wgt);

      const FinalState& fs = applyProjection<FinalState>(event, "FS");
      const FastJets& alljets = applyProjection<FastJets>(event, "Jets");
      const Jets& ptjets = alljets.jetsByPt(30.*GeV);   
      const Particles& allPtls = event.allParticles();

      // check Z' radiation
      int nRad = 0;
      for(const auto& p: allPtls){
          if( p.abspid()==32 && p.hasChildWith(Cuts::abspid==13) )
              nRad++;
      }
      _n_rad->fill(nRad,wgt);

      if( nRad<1 ) vetoEvent;
      _n_evt->fill(1,wgt);

      Particles muons;
      for(const Particle& p : fs.particles()) {
        if( p.abspid()==13 && p.abseta()<2.5 ) muons.push_back(p);
      }

      // Event selection
      Jets jets;
      for(const auto& jet_:ptjets){
          bool pushJet = false;
          if( !(jet_.pt() > 30. && jet_.abseta() < 2.4) ) continue;
          if( !(jet_.bTagged()) ) continue;
          Particles nisoMuons;
          for(const auto& muon: muons){
              if( !(muon.pt()>13. && muon.abseta()<2.4 ) ) continue;
              if( !(deltaR(muon.momentum(),jet_.momentum())<0.3) ) continue;
              nisoMuons.push_back(muon);
          }
          if( nisoMuons.size()<2 ) continue;
          for(const auto& mu1: nisoMuons){
              for(const auto& mu2: nisoMuons){
                  if( &mu1==&mu2 ) continue;
                  if( mu1.charge()*mu2.charge()>0 ) continue;
                  if( !(mu1.pt()>32.) ) continue;
                  //if( !( (mu1.pt()+mu2.pt())/jet_.pt()<0.7 ) ) continue;
                  pushJet = true;
              }
          }
          if( pushJet ) jets.push_back(jet_);
      }
      for(const auto& jet_:jets) {
        _h_ptj->fill(jet_.pt(),wgt);
        _n_evt->fill(2,wgt);
      }

    }

    /// Normalise histograms etc., after the run
    void finalize() {
      double weight = crossSection()/sumOfWeights()/femtobarn;

      scale(_n_evt, weight );
      scale(_n_rad, weight );
      scale(_h_ptj, weight );
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
    Histo1DPtr _n_rad;
    Histo1DPtr _h_ptj;
    //@}
  };

  // The hook for the plugin system
  DECLARE_RIVET_PLUGIN(RAnalysis);
}
