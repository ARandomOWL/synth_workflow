set LIB_DB_STRING ${LIB_ROOT}/synopsys/fsd0a_a_generic_core_tt1v25c.db
lappend search_path ${LIB_ROOT}/synopsys/

set LIB_DB {}
lappend LIB_DB $LIB_DB_STRING

set link_library $LIB_DB
set target_library $LIB_DB
set symbol_library {${LIB_ROOT}/synopsys/fsd0a_a_generic_core_tt1v25c.sdb}

set PT_LIB $LIB_DB
lappend PT_LIB $::env(DGATELEVEL)/$DESIGN.v
