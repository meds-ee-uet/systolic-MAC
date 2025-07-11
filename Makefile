# =======================
# ModelSim + GTKWave Flow
# =======================

# Directories
RTL_DIR       := rtl
TB_DIR        := testbench
BUILD_DIR     := build

# Files
DESIGN_FILES  := $(wildcard $(RTL_DIR)/*.sv)
TB_FILES      := $(wildcard $(TB_DIR)/*.sv)
VCD_FILE      := wave.vcd

# Tools
VLOG          := vlog
VSIM          := vsim
GTKWAVE       := gtkwave

# Top module name (must match your testbench module)
TOP_MODULE    := data_feeder_tb

# Simulation flags
VSIM_FLAGS    := -c -do "run -all; quit" +vcdfile=$(VCD_FILE) +vcdon

# ====================
# Build + Run + View
# ====================

# Default target
all: run

# Compile SV files into ModelSim work library
compile:
	@mkdir -p $(BUILD_DIR)
	$(VLOG) -work $(BUILD_DIR) $(DESIGN_FILES) $(TB_FILES)

# Simulate using ModelSim
sim: compile
	$(VSIM) -work $(BUILD_DIR) $(VSIM_FLAGS) $(TOP_MODULE)

# Open GTKWave
wave:
	$(GTKWAVE) $(VCD_FILE) myview.sav

# Run full flow
run: sim wave

# Clean simulation outputs
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(VCD_FILE) transcript vsim.wlf
	clear
