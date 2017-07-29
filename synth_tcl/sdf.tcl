source $::env(DSYNTHGENERIC)/load_jordan.tcl

lappend search_path $::env(DGATELEVEL)

set analyze_design {}
lappend analyze_design ${DESIGN}.v
analyze -format verilog $analyze_design
elaborate ${DESIGN}

write_sdf $::env(DSDF)/${DESIGN}_${LIB_SPEC}.sdf

cd $::env(DREPORTS)/${DESIGN}
source $::env(DSYNTHGENERIC)/save_reports.tcl

exit
