source $::env(DSYNTHGENERIC)/loadlib.tcl
set link_path ${PT_LIB}

variable power_enable_analysis true
read_verilog $::env(DGATELEVEL)/${DESIGN}_${LIB_NAME}.v
current_design ${DESIGN}

source $::env(DSYNTHTCL)/${DESIGN}_pt.tcl

read_vcd $::env(DVCD)/${DESIGN}_${LIB_SPEC}.vcd -strip "${DESIGN}_tb/dut"

cd $::env(DREPORTS)/${DESIGN}
report_power > power_pt_${LIB_SPEC}.rpt
report_timing > timing_pt_${LIB_SPEC}.rpt

if {$::env(NO_EXIT) eq ""} { exit }
