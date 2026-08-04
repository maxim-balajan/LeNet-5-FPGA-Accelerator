#----------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-only
#
# A hardware accelerated exp2 calculation aimed for FPGAs.
# 
# Copyright (C) 2026 Maxim Balajan (maxim.balajan@fau.de)
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#----------------------------------------------------------------------------

# Check if the PRJ_ROOT_PATH environment variable is set
if {![info exists ::env(PRJ_ROOT_PATH)]} {
    puts "ERROR: Environment variable PRJ_ROOT_PATH is not set."
    exit 1
}
set PRJ_ROOT_PATH $::env(PRJ_ROOT_PATH)
set HOME $::env(HOME)
set PROJECT_NAME "COMPARE-TREE"
set PROJECT_DIR "${PRJ_ROOT_PATH}/IP-Cores/${PROJECT_NAME}"

create_project $PROJECT_NAME $PROJECT_DIR -part xczu3eg-sbva484-1-i -force

set origin_dir "."

set obj [current_project]
set_property -name "board_part_repo_paths" -value "[file normalize "$PRJ_ROOT_PATH/bdf"]" -objects $obj
set_property -name "board_part" -value "avnet.com:ultra96v2:part0:1.2" -objects $obj
set_property target_language VHDL -objects $obj
set_property simulator_language VHDL -objects $obj


# Add all source files from $PRJ_ROOT_PATH/sources_1
set SOURCE_DIR "$PRJ_ROOT_PATH/sources_1/int_comp_tree/src"
if {[file exists $SOURCE_DIR]} {
    set sources [glob -nocomplain -directory $SOURCE_DIR -types f *.{vhd}]
    if {[llength $sources] > 0} {
        add_files -norecurse $sources
        foreach file $sources {
            set_property file_type "VHDL" [get_files $file]
        }
    } else {
        puts "WARNING: No source files found in $SOURCE_DIR"
    }
} else {
    puts "WARNING: Source directory $SOURCE_DIR does not exist."
}

# Set the wrapper as the top module
set_property top comparator_unit [current_fileset]

# Update compile order
update_compile_order -fileset sources_1

puts "Project $PROJECT_NAME created successfully at $PROJECT_DIR"

puts "Starting OOC Synthesis and Implementation Runs for $PROJECT_NAME"

# Setup synthesis for ooc mode
add_files -fileset constrs_1 -norecurse "$origin_dir/ooc_constraints.xdc"

puts "Create OOC Runs for $PROJECT_NAME ..."
create_run synth_ooc -flow {Vivado Synthesis 2023}
# double
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context -generic {G_INPUT_AMOUNT=8 G_BIT_WIDTH=11 G_INIT_PIPELINE_STEPS=3}} -objects [get_runs synth_ooc]
current_run synth_ooc

create_run impl_ooc -parent_run synth_ooc -flow {Vivado Implementation 2023}
current_run impl_ooc

puts "Start OOC synthesis for $PROJECT_NAME ..."
launch_runs synth_ooc
wait_on_run synth_ooc

puts "Start OOC routing for $PROJECT_NAME ..."
launch_runs impl_ooc
wait_on_run impl_ooc

puts "Finished OOC implementation for $PROJECT_NAME !"
