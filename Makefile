export ROOT=$(shell pwd)

include $(ROOT)/config.mk
include $(DWORKFLOW)/loadlib_$(LIB_NAME).mk
export LIB_SPEC=$(LIB_NAME)_$(LIB_OPT)$(LIB_STACKED)_$(LIB_V)_$(LIB_TEMP)

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
synth:		$(DGATELEVEL)/$(DESIGN)_$(LIB_NAME).v
sdf-reports:	$(DREPORTS)/$(DESIGN)/qor_$(LIB_SPEC).rpt

### OPEN SYNTHESIS TOOL ###
synth-tool:
	mkdir -p $(DSYNTH)
	cd $(DSYNTH) && NO_EXIT=1 $(SYNTHTOOL) -f $(DSYNTHGENERIC)/gate-level.tcl

### BEHAVIOURAL SIMULATION ###
sim-behav: $(DHDL)/$(DESIGN).sv $(DTB)/$(DESIGN)_tb.sv
	@tput bold && echo -e "========== Running behavioural simulation..." && tput sgr0
	ncverilog -sv +ncaccess+r +ncsdf_precision+1ps +nctimescale+10ps/1ps   \
		+ncoverride_precision -y $(DHDL) +incdir+$(DHDL) +libext+.sv   \
		+simvisargs+"-input $(DSIMTCL)/$(DESIGN).svcf"                 \
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
	$(DSDF)/$(DESIGN)_$(LIB_SPEC).sdf $(DGATELEVEL)/$(DESIGN)_$(LIB_NAME).v
	$(if -f "$(DGATELEVEL)/$(DESIGN)_gen.v", \
		genfile="$(DGATELEVEL)/$(DESIGN)_gen.v")
	@tput bold && echo -e "========== Running gate-level simulation ($(DESIGN) for $(LIB_SPEC))..." && tput sgr0
	mkdir -p $(DVCD)
	mkdir -p $(DREPORTS)/$(DESIGN)
	mkdir -p $(DSIM)
	cd $(DSIM) && ncverilog -sv +ncaccess+r +ncsdf_precision+1ps +nctimescale+10ps/1ps  \
		+ncoverride_precision +neg_tchk                               \
		+define+GATE_LEVEL \
		+define+TB_RESULT_PATH=\"$(DREPORTS)/$(DESIGN)\" \
		+define+LIB_V=\"$(LIB_V)\" \
		+define+LIB_TEMP=\"$(LIB_TEMP)\"       \
		+define+LIB_SPEC=\"$(LIB_SPEC)\"                              \
		+define+DESIGN=\"$(DESIGN)\"                              \
		+define+DVCD=\"$(DVCD)\"                              \
		+define+DSDF=\"$(DSDF)\"                              \
		-y $(DHDL) +incdir+$(DHDL)                                  \
		+simvisargs+"-input $(DSIMTCL)/$(DESIGN).svcf"               \
		$(LIB_VERILOG)                                        \
		$(DTB)/$(DESIGN)_tb.sv                                        \
		$(DGATELEVEL)/$(DESIGN)_$(LIB_NAME).v                                      \
		$(genfile)							\
		$(if $(SHOW_GUI), -gui)

### SDF GENERATION ###
$(DSDF)/$(DESIGN)_$(LIB_SPEC).sdf \
	$(DREPORTS)/$(DESIGN)/qor_$(LIB_SPEC).rpt                  \
	$(DREPORTS)/$(DESIGN)/ref_$(LIB_SPEC).rpt                  \
	$(DREPORTS)/$(DESIGN)/area_$(LIB_SPEC).rpt                 \
	$(DREPORTS)/$(DESIGN)/timing_$(LIB_SPEC).rpt               \
	$(DREPORTS)/$(DESIGN)/power_$(LIB_SPEC).rpt:               \
	$(DGATELEVEL)/$(DESIGN)_$(LIB_NAME).v  $(DSYNTHGENERIC)/sdf.tcl
	@tput bold && echo -e "========== Generating SDF ($(DESIGN) for $(LIB_SPEC))..." && tput sgr0
	mkdir -p $(DSDF)
	mkdir -p $(DSYNTH)
	cd $(DSYNTH) && $(SYNTHTOOL) -f $(DSYNTHGENERIC)/sdf.tcl

### SYNTHESIS ###
$(DGATELEVEL)/$(DESIGN)_$(LIB_NAME).v: \
	$(DHDL)/$(DESIGN).sv $(DSYNTHTCL)/$(DESIGN).tcl         \
	$(DSYNTHGENERIC)/synth.tcl $(DSYNTHGENERIC)/loadlib.tcl $(DSYNTHGENERIC)/loadlib_$(LIB_NAME).tcl
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
	rm -f $(DGATELEVEL)/$(DESIGN)_$(LIB_NAME).v
clean-sdf-int:
clean-sdf: clean-sdf-int
	rm -f $(DSDF)/$(DESIGN)_$(LIB_SPEC).sdf
clean-sim-int:
	rm -rf $(DSIM)/ncverilog.log $(DSIM)/ncverilog.key $(DSIM)/INCA_libs/
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
