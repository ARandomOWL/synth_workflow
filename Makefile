export ROOT=$(shell pwd)
export DWORKFLOW=$(ROOT)/workflow

### Directory paths
# Sources
export DHDL=$(ROOT)/src/hdl
export DTB=$(ROOT)/src/tb
export DSYNTHGENERIC=$(DWORKFLOW)/synth_tcl
export DSYNTHTCL=$(ROOT)/src/synth_tcl
DSIMTCL=$(DWORKFLOW)/src/sim_tcl
# Products
export DGATELEVEL=$(ROOT)/gate-level
export DREPORTS=$(ROOT)/reports
# Intermediates
export DSDF=$(ROOT)/sdf
export DVCD=$(ROOT)/vcd
export DSYNTH=$(ROOT)/dc_syn
export DPT=$(ROOT)/pt
export DSIM=$(ROOT)/sim

SYNTHTOOL=dc_shell-xg-t

### Defaults
export DESIGN=adder_dr
export LIB_ROOT=~/jordan-cells
export LIB_V=0p250v
export LIB_OPT=100N
export LIB_STACKED=
export LIB_TEMP=25c
export LIB_SPEC=$(LIB_OPT)$(LIB_STACKED)_$(LIB_V)_$(LIB_TEMP)
export NO_EXIT=
SHOW_GUI=

.PHONY: all				\
	load-module			\
	synth-tool sim-behav            \
	reports sim-gate sdf synth synth-reports	\
	clean-synth-int clean-synth	\
	clean-sdf-int clean-sdf		\
       	clean-sim-int clean-sim		\
       	clean-reports-int clean-reports \
	clean-int clean-all clean-dirs clean

### ALIAS ###
all:		reports
reports:	$(DREPORTS)/$(DESIGN)/power_pt_$(LIB_SPEC).rpt
sim-gate:	$(DVCD)/$(DESIGN)_$(LIB_SPEC).vcd
sdf:		$(DSDF)/$(DESIGN)_$(LIB_SPEC).sdf
synth:		$(DGATELEVEL)/$(DESIGN).v
sdf-reports:	$(DREPORTS)/$(DESIGN)/qor_$(LIB_SPEC).rpt

### OPEN SYNTHESIS TOOL ###
synth-tool:
	mkdir -p $(DSYNTH)
	cd $(DSYNTH) && NO_EXIT=1 $(SYNTHTOOL) -f $(DSYNTHGENERIC)/load_jordan.tcl

### BEHAVIOURAL SIMULATION ###
sim-behav:
	@tput bold && echo -e "========== Running behavioural simulation..." && tput sgr0
	ncverilog -sv +ncaccess+r +ncsdf_precision+1ps +nctimescale+10ps/1ps   \
		+ncoverride_precision -y $(DHDL) +incdir+$(DHDL) +libext+.sv   \
		+simvisargs+"-input $(DSIMTCL)/$1.svcf"                           \
		$(DTB)/$(DESIGN)_tb.sv                                         \
		$(DHDL)/$(DESIGN).sv	                                       \
		$(if $(SHOW_GUI), -gui)

### PRIMETIME REPORTS ###
$(DREPORTS)/$(DESIGN)/power_pt_$(LIB_SPEC).rpt \
	$(DREPORTS)/$(DESIGN)/timing_pt_$(LIB_SPEC).rpt: \
	$(DVCD)/$(DESIGN)_$(LIB_SPEC).vcd $(DSYNTHTCL)/$(DESIGN)_pt.tcl \
	$(DSYNTHGENERIC)/pt.tcl
	@tput bold && echo -e "========== Generating PrimeTime reports ($(DESIGN) for $(LIB_SPEC))..." && tput sgr0
	mkdir -p $(DREPORTS)/$(DESIGN)
	mkdir -p $(DPT)
	cd $(DPT) && pt_shell -f $(DSYNTHGENERIC)/pt.tcl

### GATE-LEVEL SIMULATION ###
$(DVCD)/$(DESIGN)_$(LIB_SPEC).vcd $(DREPORTS)/$(DESIGN)/perf_$(LIB_SPEC): \
	$(DSDF)/$(DESIGN)_$(LIB_SPEC).sdf $(DGATELEVEL)/$(DESIGN).v
	$(if -f "$(DGATELEVEL)/$(DESIGN)_gen.v", \
		genfile="$(DGATELEVEL)/$(DESIGN)_gen.v")
	@tput bold && echo -e "========== Running gate-level simulation ($(DESIGN) for $(LIB_SPEC))..." && tput sgr0
	mkdir -p $(DVCD)
	mkdir -p $(DREPORTS)/$(DESIGN)
	mkdir -p $(DSIM)
	cd $(DSIM) && ncverilog -sv +ncaccess+r +ncsdf_precision+1ps +nctimescale+10ps/1ps  \
		+ncoverride_precision +neg_tchk                               \
		+define+GATE_LEVEL +define+TB_RESULT_PATH=\"$(DREPORTS)/$(DESIGN)\" \
		+define+LIB_V=\"$(LIB_V)\" +define+LIB_TEMP=\"$(LIB_TEMP)\"       \
		+define+LIB_SPEC=\"$(LIB_SPEC)\"                              \
		-y $(DHDL) +incdir+$(DHDL)                                  \
		+simvisargs+"-input $(DSIMTCL)/$(DESIGN).svcf"               \
		$(LIB_ROOT)/jordan.v                                          \
		$(LIB_ROOT)/jordan_D.v                                        \
		$(DTB)/$(DESIGN)_tb.sv                                        \
		$(DGATELEVEL)/$(DESIGN).v                                      \
		$(genfile)							\
		$(if $(SHOW_GUI), -gui)

### SDF GENERATION ###
$(DSDF)/$(DESIGN)_$(LIB_SPEC).sdf \
	$(DREPORTS)/$(DESIGN)/qor_$(LIB_SPEC).rpt                  \
	$(DREPORTS)/$(DESIGN)/ref_$(LIB_SPEC).rpt                  \
	$(DREPORTS)/$(DESIGN)/area_$(LIB_SPEC).rpt                 \
	$(DREPORTS)/$(DESIGN)/timing_$(LIB_SPEC).rpt               \
	$(DREPORTS)/$(DESIGN)/power_$(LIB_SPEC).rpt:               \
	$(DGATELEVEL)/$(DESIGN).v  $(DSYNTHGENERIC)/sdf.tcl
	@tput bold && echo -e "========== Generating SDF ($(DESIGN) for $(LIB_SPEC))..." && tput sgr0
	mkdir -p $(DSDF)
	mkdir -p $(DSYNTH)
	cd $(DSYNTH) && $(SYNTHTOOL) -f $(DSYNTHGENERIC)/sdf.tcl

### SYNTHESIS ###
$(DGATELEVEL)/$(DESIGN).v: \
	$(DHDL)/$(DESIGN).sv $(DSYNTHTCL)/$(DESIGN).tcl         \
	$(DSYNTHGENERIC)/synth.tcl
	@tput bold && echo -e "========== Synthesizing ($(DESIGN) for $(LIB_SPEC))" && tput sgr0
	mkdir -p $(DREPORTS)/$(DESIGN)
	mkdir -p $(DGATELEVEL)
	mkdir -p $(DSDF)
	mkdir -p $(DSYNTH)
	cd $(DSYNTH) && $(SYNTHTOOL) -f $(DSYNTHGENERIC)/synth.tcl

load-module:

### CLEAN ###
clean-sim-behav: clean-sim-int
clean-synth-int:
	rm -rf $(DSYNTH)
clean-synth: clean-synth-int
	rm -f $(DGATELEVEL)/$(DESIGN).v
clean-sdf-int:
clean-sdf: clean-sdf-int
	rm -f $(DSDF)/$(DESIGN)_$(LIB_SPEC).sdf
clean-sim-int:
	rm -rf $(DSIM)/ncverilog.log $(DSIM)/INCA_libs/
clean-sim-sdf:
	rm -f $(DSIM)/$(DESIGN)_$(LIB_SPEC).sdf.X
clean-sim: clean-sim-int clean-sim-sdf
	rm -f $(DVCD)/$(DESIGN)_$(LIB_SPEC).vcd \
		$(DREPORTS)/$(DESIGN)/perf_$(LIB_SPEC).rpt
clean-reports-int:
	rm -rf $(DPT)
clean-reports: clean-reports-int clean-dirs
	rm -f $(DREPORTS)/$(DESIGN)/qor_$(LIB_SPEC).rpt \
		$(DREPORTS)/$(DESIGN)/ref_$(LIB_SPEC).rpt \
		$(DREPORTS)/$(DESIGN)/area_$(LIB_SPEC).rpt \
		$(DREPORTS)/$(DESIGN)/timing_$(LIB_SPEC).rpt \
		$(DREPORTS)/$(DESIGN)/power_$(LIB_SPEC).rpt  \
		$(DREPORTS)/$(DESIGN)/timing_pt_$(LIB_SPEC).rpt \
		$(DREPORTS)/$(DESIGN)/power_pt_$(LIB_SPEC).rpt
clean-post-synth: clean-sdf-int clean-sim-int \
		  clean-sdf clean-sim
clean-int: clean-synth-int clean-sdf-int clean-sim-int clean-reports-int
clean-all: clean-int clean-synth clean-sdf clean-sim clean-dirs
clean-dirs:
	rmdir -p $(DREPORTS)/$(DESIGN) $(DSIM) $(DSDF) $(DVCD) $(DGATELEVEL) $(DSYNTH) $(DPT) 2> /dev/null ; true
clean: clean-all
