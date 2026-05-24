"""
tDCS Simulation — Subject 04
Montage : C3 (anode, left M1) + Fp2 (cathode, right supraorbital)
Current : 2 mA
Electrodes: 5x5 cm rectangular pads
"""

import simnibs

s = simnibs.sim_struct.SESSION()
s.subpath  = 'm2m_sub04'          # head model folder
s.pathfem  = 'tDCS_sim_C3_Fp2'   # output folder

tdcs = s.add_tdcslist()
tdcs.currents = [0.002, -0.002]   # +2 mA anode, -2 mA cathode

# --- Anode: C3 (left primary motor cortex) ---
anode = tdcs.add_electrode()
anode.channelnr  = 1
anode.centre     = 'C3'
anode.shape      = 'rect'
anode.dimensions = [50, 50]       # 5x5 cm (in mm)
anode.thickness  = 4              # gel layer thickness (mm)

# --- Cathode: Fp2 (right supraorbital) ---
cathode = tdcs.add_electrode()
cathode.channelnr  = 2
cathode.centre     = 'Fp2'
cathode.shape      = 'rect'
cathode.dimensions = [50, 50]     # 5x5 cm (in mm)
cathode.thickness  = 4

simnibs.run_simnibs(s)
