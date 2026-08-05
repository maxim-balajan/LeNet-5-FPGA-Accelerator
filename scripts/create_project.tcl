# ============================================================
# Creates the Vivado project for the LeNet-5 accelerator from scratch.
#
#   source ./INIT.sh
#   prj_vivado_project
#
# All paths come from the variables INIT.sh exports.
#
# Expects:
#   $PRJ_ROOT_PATH/bdf                     Ultra96-v2 board files
#   $PRJ_SCRIPTS/lenet_accel_main_bd.tcl   block design
#   $PRJ_SCRIPTS/synth.tcl                 synthesis + implementation runs
# ============================================================

# Check if the PRJ_ROOT_PATH environment variable is set
if {![info exists ::env(PRJ_ROOT_PATH)]} {
    puts "ERROR: Environment variable PRJ_ROOT_PATH is not set."
    puts "ERROR: Run 'source ./INIT.sh' first."
    exit 1
}
set PRJ_ROOT_PATH $::env(PRJ_ROOT_PATH)

# Reads one of the project variables exported by INIT.sh, with a fallback so that the
# script also works when only PRJ_ROOT_PATH is set.
proc prj_env {name default} {
    if {[info exists ::env($name)]} {
        return $::env($name)
    }
    return $default
}

set PRJ_SCRIPTS          [prj_env PRJ_SCRIPTS          "$PRJ_ROOT_PATH/scripts"]
set PRJ_HW_SOURCES_PATH  [prj_env PRJ_HW_SOURCES_PATH  "$PRJ_ROOT_PATH/sources_1"]
set PRJ_DATA_PATH        [prj_env PRJ_DATA_PATH        "$PRJ_ROOT_PATH/data"]

# Prefer the interpreter of the virtual environment that INIT.sh creates
set PRJ_PYTHON "$PRJ_ROOT_PATH/.venv/bin/python"
if {![file exists $PRJ_PYTHON]} {
    set PRJ_PYTHON "python3"
}

# Check if the build directory exists, and create it if not.
if {![file exists "${PRJ_ROOT_PATH}/build/"]} {
    puts "Creating build directory ${PRJ_ROOT_PATH}/build/"
    file mkdir "${PRJ_ROOT_PATH}/build/"
}

set PROJECT_NAME "LeNet-Accelerator"
set PROJECT_DIR "${PRJ_ROOT_PATH}/build/${PROJECT_NAME}"
set BD_NAME "Top_Level_250MHz"

create_project $PROJECT_NAME $PROJECT_DIR -part xczu3eg-sbva484-1-i -force

set obj [current_project]
set_property -name "board_part_repo_paths" -value "[file normalize "$PRJ_ROOT_PATH/bdf"]" -objects $obj
set_property -name "board_part" -value "avnet.com:ultra96v2:part0:1.2" -objects $obj
set_property target_language VHDL -objects $obj
set_property simulator_language VHDL -objects $obj

# ============================================================
# Regenerate the BRAM initialisation files
#
# Every BRAM tile reads its own file out of data/output. Those files are derived from
# the raw layer_weight_*.data by data/generate_bram_data.py, so regenerate them here to
# make sure the project never gets built against a stale set.
# ============================================================
set GENERATOR "$PRJ_DATA_PATH/generate_bram_data.py"
if {[file exists $GENERATOR]} {
    if {[catch {exec $PRJ_PYTHON $GENERATOR} result]} {
        puts "WARNING: could not run $GENERATOR ($result)"
        puts "WARNING: make sure the generated BRAM data is up to date"
    } else {
        puts $result
    }
} else {
    puts "WARNING: $GENERATOR not found, assuming data/output is up to date"
}

# ============================================================
# Source files
#
# The design is VHDL-93, so the files are added as plain "VHDL" and NOT as "VHDL 2008".
# ============================================================
proc add_vhdl_dir {dir} {
    if {![file exists $dir]} {
        puts "WARNING: Source directory $dir does not exist."
        return
    }
    set sources [glob -nocomplain -directory $dir -types f *.{vhd}]
    if {[llength $sources] == 0} {
        puts "WARNING: No source files found in $dir"
        return
    }
    add_files -norecurse $sources
    foreach file $sources {
        set_property file_type "VHDL" [get_files $file]
    }
}

# Every module lives in its own <module>/src folder, the memories are collected in one
# flat memory folder. The test benches under <module>/sim are deliberately not added,
# they are run with VUnit and GHDL.
foreach dir [lsort [glob -nocomplain -directory $PRJ_HW_SOURCES_PATH -types d *]] {
    if {[file exists "$dir/src"]} {
        add_vhdl_dir "$dir/src"
    }
}
add_vhdl_dir "$PRJ_HW_SOURCES_PATH/memory"

# ============================================================
# The BRAM files are opened with paths relative to "../data/...", which is what the GHDL
# flow uses. Vivado runs synthesis and simulation from their own directories, so put a
# copy of the data next to each of them.
# ============================================================
#proc install_data {src dst} {
#    file mkdir $dst
#    file delete -force "$dst/data"
#    file copy -force $src "$dst/data"
#}
#install_data "$PRJ_DATA_PATH" "$PROJECT_DIR/${PROJECT_NAME}.runs"

## ============================================================
## Include the Block Design TCL script
## ============================================================
source "$PRJ_SCRIPTS/${BD_NAME}.tcl"

# Validate and Save the block design
validate_bd_design
save_bd_design

# ============================================================
# Generate wrapper from the BD and set it as top
# ============================================================
set bd_path "$PROJECT_DIR/${PROJECT_NAME}.srcs/sources_1/bd/${BD_NAME}/${BD_NAME}.bd"

make_wrapper -files [get_files $bd_path] -top

add_files "$PROJECT_DIR/${PROJECT_NAME}.gen/sources_1/bd/${BD_NAME}/hdl/${BD_NAME}_wrapper.vhd"

set_property top ${BD_NAME}_wrapper [current_fileset]

update_compile_order -fileset sources_1

puts "Project $PROJECT_NAME created successfully at $PROJECT_DIR"

puts "Starting Synthesis and Implementation Runs for $PROJECT_NAME"

source "$PRJ_SCRIPTS/synth.tcl"
