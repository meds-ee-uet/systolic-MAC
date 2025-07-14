###############################################################################
# Generalized ModelSim + GTKWave flow
#
# Usage:
#   make TOP=<tb_name> lib      – create work library
#   make TOP=<tb_name> compile  – compile RTL and selected TB
#   make TOP=<tb_name> sim      – run simulation & create VCD
#   make TOP=<tb_name> wave     – open GTKWave
#   make TOP=<tb_name> all      – run the whole flow (lib → compile → sim → wave)
#   make clean                  – remove generated files
###############################################################################

# ----------- user‑configurable variables -------------------------------------
RTL_DIR      := rtl
TB_DIR       := testbench

# TOP: override when calling make
TOP          ?= data_feeder
TOP_TB       := $(TOP)_tb
VCD_FILE     := $(TOP).vcd          # expects $dumpfile in TB matches this
SIM_TIME_CMD := run -all
# -----------------------------------------------------------------------------

BUILD_DIR := build
WORK_LIB  := $(BUILD_DIR)/work

VLIB := vlib
VLOG := vlog
VSIM := vsim

$(shell mkdir -p $(BUILD_DIR))

lib:
	$(VLIB) $(WORK_LIB)

compile: lib
	$(VLOG) -work $(WORK_LIB) "$(RTL_DIR)"/$(TOP).sv "$(TB_DIR)"/$(TOP_TB).sv

sim: compile
	$(VSIM) $(TOP_TB) -c -lib $(WORK_LIB) \
	-do "transcript on; $(SIM_TIME_CMD); quit" \
	> $(BUILD_DIR)/transcript.txt
	@echo "Simulation complete. Transcript saved to $(BUILD_DIR)/transcript.txt"

wave: sim
	gtkwave $(VCD_FILE) &

all: lib compile sim wave

clean:
	rm -rf $(WORK_LIB) vsim.wlf *.vcd $(BUILD_DIR)/transcript.txt

.PHONY: lib compile sim wave all clean
