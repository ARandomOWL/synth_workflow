set link_library ""
lappend search_path $::env(DHDL)

analyze -format sverilog $::env(DHDL)/$::env(DESIGN).sv
elaborate $::env(DESIGN)
