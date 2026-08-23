# Synthesis Tcl Script for Cadence Genus

# HDL Language Specification
set HDL_LANGUAGE v2001

# Project Directories and Paths
set PROJ_DIR        "."
set RTL_PATH        "."
set SDC_PATH        "."

# All HDL files, separated by spaces
set RTL_LIST {contador_sincrono.v cdc.v compare.v top.v}

# Top-level module name for synthesis
set DESIGN          "top"

# PDK Library and LEF Paths
set LIB_PATH        "/opt/pdks/asap7/asap7sc7p5t_28/LIB/NLDM/"
set LEF_PATH        "/opt/pdks/asap7/asap7sc7p5t_28/LEF/scaled/"
set TLEF_PATH       "/opt/pdks/asap7/asap7sc7p5t_28/techlef_misc/"
set QRC_PATH        "/opt/pdks/asap7/asap7sc7p5t_28/qrc/"

# Baseline LIB files
set LIB_LIST {  asap7sc7p5t_AO_LVT_TT_nldm_211120.lib   asap7sc7p5t_INVBUF_LVT_TT_nldm_220122.lib   asap7sc7p5t_OA_LVT_TT_nldm_211120.lib   asap7sc7p5t_SEQ_LVT_TT_nldm_220123.lib   asap7sc7p5t_SIMPLE_LVT_TT_nldm_211120.lib \
        asap7sc7p5t_AO_SLVT_TT_nldm_211120.lib  asap7sc7p5t_INVBUF_SLVT_TT_nldm_220122.lib  asap7sc7p5t_OA_SLVT_TT_nldm_211120.lib  asap7sc7p5t_SEQ_SLVT_TT_nldm_220123.lib  asap7sc7p5t_SIMPLE_SLVT_TT_nldm_211120.lib}

# Baseline LEF files
set LEF_LIST { asap7_tech_4x_201209.lef asap7sc7p5t_28_L_4x_220121a.lef asap7sc7p5t_28_R_4x_220121a.lef asap7sc7p5t_28_SL_4x_220121a.lef}

# Setup super-threading
set_db max_cpus_per_server 100
set_db super_thread_servers "localhost"

# Configure synthesis parameters
set_db init_lib_search_path "${LIB_PATH} ${LEF_PATH} ${TLEF_PATH}"
set_db init_hdl_search_path ${RTL_PATH} 
set_db / .library "${LIB_LIST}"
set_db lef_library "${LEF_LIST}"

# Read LIBS and LEFS
read_libs ${LIB_LIST}
read_physical -lef ${LEF_LIST}

# Tool verbosity level
set_db information_level 5

# Elaborate the top-level design
read_hdl -language ${HDL_LANGUAGE} ${RTL_LIST}
elaborate ${DESIGN}
check_design -unresolved

# Timing constraints
read_sdc ${SDC_PATH}/timing_constraints.sdc

# Synthesis effort configuration
set_db syn_generic_effort low
set_db syn_map_effort low
set_db syn_opt_effort low

# Synthesis steps
# --- GENERIC LOGIC
syn_generic
# --- TECHNOLOGY MAPPING
syn_map
# --- OPTMIZATION
syn_opt

# Generate reports
report_area
report_qor

# Define report files
report timing > ${PROJ_DIR}/reports/${DESIGN}_timing.rep 
report gates  > ${PROJ_DIR}/reports/${DESIGN}_cell.rep 
report area   > ${PROJ_DIR}/reports/${DESIGN}_area.rep 
report power  > ${PROJ_DIR}/reports/${DESIGN}_power.rep 

# Save netlist and constraints
write_hdl > ${PROJ_DIR}/synthesis/${DESIGN}_netlist.v
write_sdc > ${PROJ_DIR}/constraints/${DESIGN}_constraints.sdc

# Show Graphic User Interface
gui_show
