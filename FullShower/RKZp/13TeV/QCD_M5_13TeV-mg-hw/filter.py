import pyhepmc as hep
import pyhepmc.io as hep_io

input_file = "LHC.hepmc"
output_file = "filtered.hepmc"

reader = hep.open(input_file, "r")
writer = hep_io.WriterAsciiHepMC2(output_file)
#writer = hep.open(output_file, "w")

#Nzp = 0

for event in reader:
    # Muon filter
    #muons = [p for p in event.particles if abs(p.pid) == 13 and p.status == 1]
    #if len(muons) == 2:  # Look for exactly two final-state muons
    #    m = invariant_mass(muons[0].momentum, muons[1].momentum)
    #    if m > 50:  # Keep only if M(mu+, mu-) > 50 GeV
    #        writer.write(event)

    # Zp filter
    zp = [p for p in event.particles if abs(p.pid) == 32]
    if len(zp) > 0:
        writer.write(event)
        #Nzp += 1
        #print("Event with Z' - ID:", event.event_number)
        #if Nzp >= 10:
        #    break

reader.close()
writer.close()
print(f"Filtered events saved to {output_file}")

