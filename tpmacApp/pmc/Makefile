# Makefie for creating PMAC programs
#
TOP = ../..
include $(TOP)/configure/CONFIG
include $(TOP)/configure/CONFIG_PMC

PMC += xf10ida-mc02-homing.pmc
PMC += xf10ida-mc02-plc05-cpu.pmc
PMC += xf10ida-mc02-brake.pmc
PMC_INSTALLS += xf10ida-mc02-plc01.pmc
PMC_TEMPLATES += PLC_cpu_load.pmc
PMC_TEMPLATES += PLC_brake.pmc
PMC_TEMPLATES += home_to_enc_ref_template.pmc

include $(TOP)/configure/RULES_PMC
