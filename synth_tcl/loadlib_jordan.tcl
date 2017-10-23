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
lappend PT_LIB $::env(DGATELEVEL)/${DESIGN}_${LIB_NAME}.v

set link_library $LIB_DB

set target_library $LIB_DB

#### Restrict cells for stacked-only
if {${LIB_STACKED} ne ""} {
	set_dont_use {cln65lp_INWERVTAPTT_tt_typical_max_${LIB_V}_${LIB_TEMP}/*}
	remove_attribute {\
		cln65lp_INWERVTAPTT_tt_typical_max_0p250v_25c/AOI22_X1F* \
		cln65lp_INWERVTAPTT_tt_typical_max_0p250v_25c/OAI22_X1F* \
		cln65lp_INWERVTAPTT_tt_typical_max_0p250v_25c/TIE* \
	} dont_use
}

