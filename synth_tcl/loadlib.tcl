set DESIGN $::env(DESIGN)

set LIB_NAME $::env(LIB_NAME)
set LIB_ROOT $::env(LIB_ROOT)
set LIB_V $::env(LIB_V)
set LIB_OPT $::env(LIB_OPT)
set LIB_STACKED $::env(LIB_STACKED)
set LIB_TEMP $::env(LIB_TEMP)
set LIB_SPEC $::env(LIB_SPEC)

source $::env(DSYNTHGENERIC)/loadlib_${LIB_NAME}.tcl
