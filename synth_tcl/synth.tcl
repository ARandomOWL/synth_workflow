source $::env(DSYNTHGENERIC)/loadlib.tcl
lappend search_path $::env(DHDL)

source $::env(DSYNTHTCL)/${DESIGN}.tcl

change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output $::env(DGATELEVEL)/${DESIGN}_${LIB_NAME}.v
write_sdf $::env(DSDF)/${DESIGN}_${LIB_SPEC}.sdf

cd $::env(DREPORTS)/${DESIGN}
source $::env(DSYNTHGENERIC)/save_reports.tcl

if {$::env(NO_EXIT) eq ""} { exit }
