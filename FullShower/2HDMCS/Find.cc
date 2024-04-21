// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/FastJets.hh"
#include <iostream>
#include <fstream>
/// @todo Include more projections as required, e.g. ChargedFinalState, FastJets, ZFinder...



namespace Rivet {


  class Find : public Analysis {
  public:

    /// Constructor
    Find()
      : Analysis("Find")
    {    }

    /// @name Analysis methods
    //@{

    /// Book histograms and initialise projections before the run
    void init() {

      // Projections
      declare(FinalState(), "FS");
      declare(FastJets(FinalState(), FastJets::ANTIKT, 0.4), "AK4Jets");

      book(_h_bsmevt,  "h_bsmevt",  2,0,2); // # of evts containing BSM particles
      book(_h_bsmptc,  "h_bsmptc",  13,0,13); // # of all BSM particles
      book(_h_bsm1,    "h_bsm1",    13,0,13); // 1st BSM particle

      book(_h_pt25,  "h_pt25",  200,0.,200.);
      book(_h_eta25, "h_eta25",  60,-3.,3.);
      book(_h_phi25, "h_phi25",  64,-3.2,3.2);
      book(_h_dR25,  "h_dR25",   40,0.,4.);

      book(_h_pt35,  "h_pt35",  200,0.,200.);
      book(_h_eta35, "h_eta35",  60,-3.,3.);
      book(_h_phi35, "h_phi35",  64,-3.2,3.2);
      book(_h_dR35,  "h_dR35",   40,0.,4.);

      book(_h_pt36,  "h_pt36",  200,0.,200.);
      book(_h_eta36, "h_eta36",  60,-3.,3.);
      book(_h_phi36, "h_phi36",  64,-3.2,3.2);
      book(_h_dR36,  "h_dR36",   40,0.,4.);

      book(_h_pt37,  "h_pt37",  200,0.,200.);
      book(_h_eta37, "h_eta37",  60,-3.,3.);
      book(_h_phi37, "h_phi37",  64,-3.2,3.2);
      book(_h_dR37,  "h_dR37",   40,0.,4.);

      book(_h_pt38,  "h_pt38",  200,0.,200.);
      book(_h_eta38, "h_eta38",  60,-3.,3.);
      book(_h_phi38, "h_phi38",  64,-3.2,3.2);
      book(_h_dR38,  "h_dR38",   40,0.,4.);

      book(_h_pt52,  "h_pt52",  200,0.,200.);
      book(_h_eta52, "h_eta52",  60,-3.,3.);
      book(_h_phi52, "h_phi52",  64,-3.2,3.2);
      book(_h_dR52,  "h_dR52",   40,0.,4.);

    }

    /// Perform the per-event analysis
    void analyze(const Event& event) {
      //setup analysis
      const double weight = 1.;

      const FinalState& fs = applyProjection<FinalState>(event, "FS");
      // find particles
      vector<int> BSMids={25,35,36,37,38,52,82,250,251,9000001,9000002,9000003,9000004};
      vector<int> NBSM={0,0,0,0,0,0,0,0,0,0,0,0,0};
      bool foundBSM=false;
      vector<Particle> founds;
      for(const Particle& p : fs.particles()) {
        //scan
        Particle candidate=p;
        for(int i=0; i<BSMids.size(); i++) {
          int target = BSMids[i];
          if(candidate.abspid()==target) {
            foundBSM=true;
            founds.push_back(candidate);
            NBSM[i]++;
          }
        }
        //if(foundBSM) cerr<<"BSM particles are found!\n";
      }
      _h_bsmevt->fill(foundBSM,weight);

      if( !foundBSM ) vetoEvent;
      for(int i=0; i<NBSM.size(); i++)
        _h_bsmptc->fill(i,weight*NBSM[i]);
      _h_bsm1->fill(founds[0].abspid(),weight);

      Jets jets = apply<FastJets>(event, "AK4Jets").jetsByPt(30.*GeV);

      for(const Particle& p : founds) {
        if(p.abspid()==25) {
          _h_pt25->fill(p.pt(),weight);
          _h_eta25->fill(p.eta(),weight);
          _h_phi25->fill(p.phi(),weight);
  
          if(jets.size()==0) continue;
          double dR = 999.;
          for(const Jet& jet : jets) {
            if(jet.eta()>3.0) continue;
            double dR_ = deltaR(jet.momentum(), p.momentum());
            if( dR_ < dR ) dR = dR_;
          }
          _h_dR25->fill(dR,weight);
        } 
        else if(p.abspid()==35) {
          _h_pt35->fill(p.pt(),weight);
          _h_eta35->fill(p.eta(),weight);
          _h_phi35->fill(p.phi(),weight);
  
          if(jets.size()==0) continue;
          double dR = 999.;
          for(const Jet& jet : jets) {
            if(jet.eta()>3.0) continue;
            double dR_ = deltaR(jet.momentum(), p.momentum());
            if( dR_ < dR ) dR = dR_;
          }
          _h_dR35->fill(dR,weight);
        } 
        else if(p.abspid()==36) {
          _h_pt36->fill(p.pt(),weight);
          _h_eta36->fill(p.eta(),weight);
          _h_phi36->fill(p.phi(),weight);
  
          if(jets.size()==0) continue;
          double dR = 999.;
          for(const Jet& jet : jets) {
            if(jet.eta()>3.0) continue;
            double dR_ = deltaR(jet.momentum(), p.momentum());
            if( dR_ < dR ) dR = dR_;
          }
          _h_dR36->fill(dR,weight);
        } 
        else if(p.abspid()==37) {
          _h_pt37->fill(p.pt(),weight);
          _h_eta37->fill(p.eta(),weight);
          _h_phi37->fill(p.phi(),weight);
  
          if(jets.size()==0) continue;
          double dR = 999.;
          for(const Jet& jet : jets) {
            if(jet.eta()>3.0) continue;
            double dR_ = deltaR(jet.momentum(), p.momentum());
            if( dR_ < dR ) dR = dR_;
          }
          _h_dR37->fill(dR,weight);
        } 
        else if(p.abspid()==38) {
          _h_pt38->fill(p.pt(),weight);
          _h_eta38->fill(p.eta(),weight);
          _h_phi38->fill(p.phi(),weight);
  
          if(jets.size()==0) continue;
          double dR = 999.;
          for(const Jet& jet : jets) {
            if(jet.eta()>3.0) continue;
            double dR_ = deltaR(jet.momentum(), p.momentum());
            if( dR_ < dR ) dR = dR_;
          }
          _h_dR38->fill(dR,weight);
        } 
        else if(p.abspid()==52) {
          _h_pt52->fill(p.pt(),weight);
          _h_eta52->fill(p.eta(),weight);
          _h_phi52->fill(p.phi(),weight);
  
          if(jets.size()==0) continue;
          double dR = 999.;
          for(const Jet& jet : jets) {
            if(jet.eta()>3.0) continue;
            double dR_ = deltaR(jet.momentum(), p.momentum());
            if( dR_ < dR ) dR = dR_;
          }
          _h_dR52->fill(dR,weight);
        } 
        else cerr<<"Something goes wrong\n";

      }
    }

    /// Normalise histograms etc., after the run
    void finalize() {
      double weight = crossSection()/sumOfWeights()/femtobarn;

      scale(_h_bsmevt, weight );
      scale(_h_bsmptc, weight );
      scale(_h_bsm1, weight );
      scale(_h_pt25, weight );
      scale(_h_eta25, weight );
      scale(_h_phi25, weight );
      scale(_h_dR25, weight );
      scale(_h_pt35, weight );
      scale(_h_eta35, weight );
      scale(_h_phi35, weight );
      scale(_h_dR35, weight );
      scale(_h_pt36, weight );
      scale(_h_eta36, weight );
      scale(_h_phi36, weight );
      scale(_h_dR36, weight );
      scale(_h_pt37, weight );
      scale(_h_eta37, weight );
      scale(_h_phi37, weight );
      scale(_h_dR37, weight );
      scale(_h_pt38, weight );
      scale(_h_eta38, weight );
      scale(_h_phi38, weight );
      scale(_h_dR38, weight );
      scale(_h_pt52, weight );
      scale(_h_eta52, weight );
      scale(_h_phi52, weight );
      scale(_h_dR52, weight );

      // data file
      std::ofstream file;
      string fname = "Find.dat";
      file.open(fname.c_str());
      file << "PLOT\n";
      file.close();
    }

    //@}


  private:

    // Data members like post-cuts event weight counters go here


    /// @name Histograms
    //@{
    Histo1DPtr _h_bsmevt;
    Histo1DPtr _h_bsmptc;
    Histo1DPtr _h_bsm1;
    Histo1DPtr _h_pt25;
    Histo1DPtr _h_eta25;
    Histo1DPtr _h_phi25;
    Histo1DPtr _h_dR25;
    Histo1DPtr _h_pt35;
    Histo1DPtr _h_eta35;
    Histo1DPtr _h_phi35;
    Histo1DPtr _h_dR35;
    Histo1DPtr _h_pt36;
    Histo1DPtr _h_eta36;
    Histo1DPtr _h_phi36;
    Histo1DPtr _h_dR36;
    Histo1DPtr _h_pt37;
    Histo1DPtr _h_eta37;
    Histo1DPtr _h_phi37;
    Histo1DPtr _h_dR37;
    Histo1DPtr _h_pt38;
    Histo1DPtr _h_eta38;
    Histo1DPtr _h_phi38;
    Histo1DPtr _h_dR38;
    Histo1DPtr _h_pt52;
    Histo1DPtr _h_eta52;
    Histo1DPtr _h_phi52;
    Histo1DPtr _h_dR52;
    //@}
  };

  // The hook for the plugin system
  DECLARE_RIVET_PLUGIN(Find);

}
