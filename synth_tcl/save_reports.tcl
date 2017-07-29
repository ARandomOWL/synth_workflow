set LIB_V $::env(LIB_V)

report_qor > qor_$LIB_SPEC.rpt
report_reference -hierarchy > ref_$LIB_SPEC.rpt
report_area > area_$LIB_SPEC.rpt
report_timing > timing_$LIB_SPEC.rpt
report_power > power_$LIB_SPEC.rpt
