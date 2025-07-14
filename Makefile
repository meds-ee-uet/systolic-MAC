###############################################################################
# ModelSim + GTKWave flow for Systolic‑MAC project
#
# Usage:
#   make lib      – create work library
#   make compile  – compile RTL and chosen TB
#   make sim      – run simulation & create VCD
#   make wave     – open GTKWave
#   make all      – run the whole flow (lib → compile → sim → wave)
#   make clean    – remove generated files
###############################################################################

# ----------- user‑configurable variables -------------------------------------
RTL_DIR      := rtl
TB_DIR       := testbench
TOP_TB       := pe_tb
VCD_FILE     := pe.vcd          # matches $dumpfile name
SIM_TIME_CMD := run -all                 # or 'run 1us' etc.
# -----------------------------------------------------------------------------


# work library is created in ./build to keep root clean
BUILD_DIR := build
WORK_LIB  := $(BUILD_DIR)/work

# ModelSim commands
VLIB := vlib
VLOG := vlog
VSIM := vsim

# Make sure build directory exists before anything else
$(shell mkdir -p $(BUILD_DIR))

# Step 1: create library

lib:
	$(VLIB) $(WORK_LIB)


# Step 2: compile RTL and the selected test‑bench
compile: lib
	$(VLOG) -work $(WORK_LIB) "$(RTL_DIR)"/*.sv "$(TB_DIR)"/$(TOP_TB).sv



# Step 3: simulate in console mode and dump VCD
sim: compile
	$(VSIM) $(TOP_TB) -c -lib $(WORK_LIB) \
	-do "transcript on; $(SIM_TIME_CMD); quit" \
	> $(BUILD_DIR)/transcript.txt
	@echo "Simulation complete. Transcript saved to build/transcript.txt"



# Step 4: open waveform in GTKWave
wave: sim
	gtkwave $(VCD_FILE) &



# Convenience target: do everything
all: lib compile sim wave



# Clean up
clean:
	rm -rf $(WORK_LIB)  vsim.wlf  $(VCD_FILE)  $(BUILD_DIR)/transcript.txt
.PHONY: lib compile sim wave all clean
