source $::env(DSYNTHGENERIC)/load_jordan.tcl
lappend search_path $::env(DHDL)

# Restrict cells for stacked-only
if {${LIB_STACKED} ne ""} {
	set_dont_use {cln65lp_INWERVTAPTT_tt_typical_max_${LIB_V}_${LIB_TEMP}/*}
	remove_attribute {\
		cln65lp_INWERVTAPTT_tt_typical_max_0p250v_25c/AOI22_X1F* \
		cln65lp_INWERVTAPTT_tt_typical_max_0p250v_25c/OAI22_X1F* \
		cln65lp_INWERVTAPTT_tt_typical_max_0p250v_25c/TIE* \
	} dont_use
}

source $::env(DSYNTHTCL)/${DESIGN}.tcl

change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output $::env(DGATELEVEL)/${DESIGN}.v
write_sdf $::env(DSDF)/${DESIGN}_${LIB_SPEC}.sdf

cd $::env(DREPORTS)/${DESIGN}
source $::env(DSYNTHGENERIC)/save_reports.tcl

if {$::env(NO_EXIT) eq ""} { exit }
