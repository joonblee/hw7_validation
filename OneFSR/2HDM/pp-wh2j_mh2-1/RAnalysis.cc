// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FinalState.hh"
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
      declare(FinalState(), "FS");

      book(_h_ptr,   "h_ptr",   50,0.,500.0);
      book(_h_etar,  "h_etar",  20,-5.,5.);
      book(_h_pti,   "h_pti",   50,0.,500.0);
      book(_h_etai,  "h_etai",  20,-5.,5.);
      book(_h_ptj,   "h_ptj",   50,0.,500.0);
      book(_h_etaj,  "h_etaj",  20,-5.,5.0);

      book(_h_dR_ri, "h_dR_ri", 100, 0., 10.);
      book(_h_dR_rj, "h_dR_rj", 100, 0., 10.);
      book(_h_dR_ij, "h_dR_ij", 80, 0., 8.);

      book(_h_m_ij,  "h_m_ij",  60,0.,600.);

      book(_h_pT,  "h_pT",  100,0.,400.0);
      book(_h_qT,  "h_qT",  120,0.,1200.0);
      book(_h_z,   "h_z",   100,0.,1.);
      //book(_n_h, "n_h", 1,0.,1.);
      //book(_s_h, "s_z_h", 50, 0.,1., 50, 0.,1.);
    }

    /// Perform the per-event analysis
    void analyze(const Event& event) {
      //setup analysis
      const double weight = 1.;

      const FinalState& fs = applyProjection<FinalState>(event, "FS");
      Particle out, recoil, branch;
      bool find_i(false), find_j(false), find_r(false);
      // find particles
      for(const Particle& p : fs.particles()) {
        if((abs(p.pid())<7||p.pid()==21)&&!find_r) {
          recoil = p;
          find_r=true;
        }
        else if(abs(p.pid())==24&&!find_i) {
          branch = p;
          find_i=true;
        }
        else if(abs(p.pid())==35/*&&(p.hasParent(24)||p.hasParent(-24))*/&&!find_j) {
          out = p;
          find_j=true;
        }
      }
      if( !find_r || !find_i || !find_j ) vetoEvent;
      if( recoil.pt() < 20. && recoil.abseta() > 5. ) vetoEvent;

      double pT2, zq;
      double m0, m1, m2;
      m0 = 79.825;
      m1 = branch.momentum().mass();
      m2 = out.momentum().mass();
      FourMomentum p = branch.momentum()+out.momentum();
      double absp3 = p.p();
      FourMomentum n;
      n.setT(1); n.setX(-p.x()/absp3); n.setY(-p.y()/absp3); n.setZ(-p.z()/absp3);
      zq = branch.momentum()*n/(p*n);
      pT2 = zq*(1.-zq)*p.invariant()-(1.-zq)*sqr(m1)-zq*sqr(m2);

      double pT, qT;
	  pT = sqrt(pT2);
      qT = sqrt(((branch.momentum()+out.momentum()).invariant()-sqr(m0))/zq/(1-zq));

      _h_pT->fill(pT);
      _h_qT->fill(qT);
      _h_z->fill(zq);

      _h_ptr->fill(recoil.pt(),weight);
      _h_etar->fill(recoil.eta(),weight);
      _h_pti->fill(branch.pt(),weight);
      _h_etai->fill(branch.eta(),weight);
      _h_ptj->fill(out.pt(),weight);
      _h_etaj->fill(out.eta(),weight);

      _h_dR_ri->fill(deltaR(recoil.momentum(),branch.momentum()),weight);
      _h_dR_rj->fill(deltaR(recoil.momentum(),out.momentum()),weight);
      _h_dR_ij->fill(deltaR(branch.momentum(),out.momentum()),weight);

      _h_m_ij->fill((branch.momentum()+out.momentum()).mass(),weight);

      //if(_scatter_h.size()<20000)
	  //    _scatter_h.push_back(make_pair(xh,xz));
	  //  _s_h->fill(xh,xz,weight);
    }

    /// Normalise histograms etc., after the run
    void finalize() {
      double weight = crossSection()/sumOfWeights()/femtobarn;

      scale(_h_pT, weight);
      scale(_h_qT, weight);
      scale(_h_z, weight);

      scale(_h_ptr, weight );
      scale(_h_etar, weight );
      scale(_h_pti, weight );
      scale(_h_etai, weight );
      scale(_h_ptj, weight );
      scale(_h_etaj, weight );

      scale(_h_dR_ri, weight );
      scale(_h_dR_rj, weight );
      scale(_h_dR_ij, weight );

      scale(_h_m_ij, weight );

      //normalize(_s_h);
      // data file
      std::ofstream file;
      string fname = "RAnalysis.dat";
      file.open(fname.c_str());
      //for(unsigned int ix=0;ix<_scatter_h.size();++ix) {
      //  file << _scatter_h[ix].first << " " <<  _scatter_h[ix].second << "\n";
      //}
      file << "PLOT\n";
      file.close();
    }

    //@}


  private:

    // Data members like post-cuts event weight counters go here


    /// @name Histograms
    //@{
    Histo1DPtr _h_pT;
    Histo1DPtr _h_qT;
    Histo1DPtr _h_z;

    Histo1DPtr _h_ptr;
    Histo1DPtr _h_etar;
    Histo1DPtr _h_pti;
    Histo1DPtr _h_etai;
    Histo1DPtr _h_ptj;
    Histo1DPtr _h_etaj;

    Histo1DPtr _h_dR_ri;
    Histo1DPtr _h_dR_rj;
    Histo1DPtr _h_dR_ij;

    Histo1DPtr _h_m_ij;

    //Histo1DPtr _n_h;
    //Histo2DPtr _s_h;
    //@}

    //vector<pair<double,double> > _scatter_h;
  };



  // The hook for the plugin system
  DECLARE_RIVET_PLUGIN(RAnalysis);


}
