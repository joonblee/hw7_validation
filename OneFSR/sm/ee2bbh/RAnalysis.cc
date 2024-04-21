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

      book(_h_dR_ri, "h_dR_ri", 20, 0., 10.);
      book(_h_dR_rj, "h_dR_rj", 20, 0., 10.);
      book(_h_dR_ij, "h_dR_ij", 20, 0., 10.);

      book(_h_m_ij,  "h_m_ij",  45,100.,1000.);

      book(_h_pT,  "h_pT",  100,0.,400.0);
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
      vector<Particle> leg;
      int Nleg=0, NH=0;
      // find particles
      for(const Particle& p : fs.particles()) {
        if(abs(p.pid())==5) {
          leg.push_back(p);
          Nleg++;
        }
        else if(abs(p.pid())==25) {
          out = p;
          NH++;
        }
      }
      if( Nleg!=2 || NH!=1 ) vetoEvent;
      if( abs(leg[0].eta()) > 5. || abs(leg[1].eta()) > 5. ) vetoEvent;

      double pT2[2], z[2];
      for(unsigned i=0; i<leg.size(); i++) {
        double m1 = leg[i].momentum().mass();
        double m2 = out.momentum().mass();
        FourMomentum p = leg[i].momentum()+out.momentum();
        double absp3 = p.p();
        FourMomentum n;
        n.setT(1); n.setX(-p.x()/absp3); n.setY(-p.y()/absp3); n.setZ(-p.z()/absp3);
        z[i] = leg[i].momentum()*n/(p*n);
        pT2[i] = z[i]*(1.-z[i])*p.invariant()-(1.-z[i])*sqr(m1)-z[i]*sqr(m2);
      }

      double pT, zq;
      if(pT2[0]>=0. && (pT2[0]<pT2[1] || pT2[1]<0.)) {
        branch = leg[0]; recoil = leg[1];
	    pT = sqrt(pT2[0]);
	    zq = z[0];
      }
      else {
        branch = leg[1]; recoil = leg[0];
	    pT = sqrt(pT2[1]);
	    zq = z[1];
      }

      _h_pT->fill(pT);
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
