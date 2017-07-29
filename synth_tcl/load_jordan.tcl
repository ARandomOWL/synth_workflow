set LIB_ROOT $::env(LIB_ROOT)
set DESIGN $::env(DESIGN)
set LIB_V $::env(LIB_V)
set LIB_OPT $::env(LIB_OPT)
set LIB_STACKED $::env(LIB_STACKED)
set LIB_TEMP $::env(LIB_TEMP)
set LIB_SPEC $::env(LIB_SPEC)

set LIB_DB_STRING $LIB_ROOT/pipistrelle4_INWE${LIB_OPT}_A12TR_r0p1/db/cln65lp_INWERVTAPTT_tt_typical_max_${LIB_V}_${LIB_TEMP}.db


if {$LIB_STACKED ne ""} {
	set LIB_DB_STRING_D $LIB_ROOT/pipistrelle4_INWE${LIB_OPT}D_A12TR_r0p1/db/cln65lp_INWERVTAPDTT_tt_typical_max_${LIB_V}_${LIB_TEMP}.db
} else {set LIB_DB_STRING_D ""}

lappend search_path $LIB_ROOT

set LIB_DB {}
lappend LIB_DB $LIB_DB_STRING
if {$LIB_STACKED ne ""} {
	lappend LIB_DB $LIB_DB_STRING_D
}

set PT_LIB $LIB_DB
lappend PT_LIB $::env(DGATELEVEL)/$DESIGN.v

set link_library $LIB_DB

set target_library $LIB_DB
