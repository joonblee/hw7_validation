from __future__ import print_function

import FWCore.ParameterSet.Config as cms

# Define the process
process = cms.Process("GEN")

# Input source: Read from the HepMC file
process.source = cms.Source("MCFileSource",
    fileNames = cms.untracked.vstring('file:./LHC.hepmc'),
)

# Set the maximum number of events to process
process.maxEvents = cms.untracked.PSet(input = cms.untracked.int32(-1))  # -1 means process all events

# Output module: Define the output ROOT file
process.GEN = cms.OutputModule("PoolOutputModule",
    fileName = cms.untracked.string('GEN.root')
)

#process.load('Configuration.StandardSequences.Services_cff') # Not necessary here but most of CMSSW configurations need this service, e.g. monitorings, random number generation, ...
process.load('SimGeneral.HepPDTESSource.pythiapdt_cfi')
#process.load('GeneratorInterface.Core.genFilterSummary_cff') # This may be useful for GEN filterings
process.load('Configuration.StandardSequences.Generator_cff')
process.genParticles.src= cms.InputTag("source","generator")

# Define the processing path
process.p = cms.Path(process.genParticles)

# Define the end path for output
process.outpath = cms.EndPath(process.GEN)
