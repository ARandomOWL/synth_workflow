source $::env(DSYNTHGENERIC)/loadlib.tcl
lappend search_path $::env(DHDL)

analyze -format verilog $::env(DGATELEVEL)/${DESIGN}_${LIB_NAME}.v
elaborate ${DESIGN}
