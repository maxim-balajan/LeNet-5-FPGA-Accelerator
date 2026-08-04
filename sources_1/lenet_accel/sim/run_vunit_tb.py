#----------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-only
#
# A LeNet-5 inference accelerator aimed for FPGAs.
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

import subprocess
import sys
from os import environ
from os.path import abspath, dirname, isfile, join

# import VUnit and project specific libraries
from vunit import VUnit

# basic setup
cur_path = dirname(abspath(__file__))
C_TB_NAME = "lenet_accel_tb"

# INIT.sh exports the project paths. Everything falls back to a path derived from this
# file, so the runner also works in a plain checkout without sourcing INIT.sh.
root_path = abspath(environ.get("PRJ_ROOT_PATH", join(cur_path, "..", "..", "..")))
data_path = abspath(environ.get("PRJ_DATA_PATH", join(root_path, "data")))
bram_data_path = abspath(environ.get("PRJ_BRAM_DATA_PATH", join(data_path, "output")))
hw_sources_path = abspath(environ.get("PRJ_HW_SOURCES_PATH", join(root_path, "sources_1")))
wave_path = join(cur_path, "default_wave.do")

###########################
# generate the BRAM data ##
###########################

# Every BRAM tile of the accelerator initialises itself from its own file in data/output.
# Those files are derived from the raw layer_weight_*.data, so regenerate them here to
# make sure the test never runs against a stale set.
generator = join(data_path, "generate_bram_data.py")
print("Generating BRAM initialisation data ...")
subprocess.check_call([sys.executable, generator])

#############
# setup TB ##
#############

my_vunit = VUnit.from_argv()
my_vunit.add_vhdl_builtins()

my_vunit.add_osvvm()

tb_lib = my_vunit.add_library("tb_lib", vhdl_standard="2008")

# Every module of the accelerator lives in its own <module>/src folder, the memories are
# collected in one flat memory folder.
tb_lib.add_source_files(join(hw_sources_path, "*", "src", "*.vhd"))
tb_lib.add_source_files(join(hw_sources_path, "memory", "*.vhd"))

# the test bench of the top level itself
tb_lib.add_source_files(join(cur_path, "testbench", "*.vhd"))

# bram_single_port uses a non protected shared variable, which VHDL-2008 only tolerates
# in relaxed mode. The design itself is VHDL-93, where it is perfectly legal.
tb_lib.set_compile_option("ghdl.a_flags", ["-frelaxed"])
tb_lib.set_sim_option("ghdl.elab_flags", ["-frelaxed"])

# add test bench configurations
#
# The data files are opened with the paths below. They are absolute so that the test does
# not depend on the directory VUnit happens to run the simulation from.
test_bench = tb_lib.test_bench(C_TB_NAME)
test_bench.add_config(
    name="tb_cfg_lenet",
    generics=dict(
        G_IMAGE_PATH_A=join(data_path, "input_2.data"),
        G_IMAGE_LABEL_A=2,
        G_IMAGE_PATH_B=join(data_path, "input_7.data"),
        G_IMAGE_LABEL_B=7,
        G_SCALE_FILE_PATH=join(data_path, "scale_values.data"),
        G_CONV_WEIGHT_PREFIX_0=join(bram_data_path, "conv_1_weights_ch"),
        G_CONV_WEIGHT_PREFIX_1=join(bram_data_path, "conv_2_weights_ch"),
        G_DENSE_WEIGHT_PREFIX=join(bram_data_path, "dense_weights_row"),
    ),
)

# Helper function to create modelsim do file, only available inside the HW sources tree
if "PRJ_HW_SOURCES_PATH" in environ:
    print("sdfsfsddffsdf")
    source_path = abspath(environ["PRJ_HW_SOURCES_PATH"])
    sys.path.append(source_path)
    try:
        from tools.cmd_wave_gen import create_modelsim_do_script

        create_modelsim_do_script(C_TB_NAME, wave_path)
    except ImportError:
        pass

################
## execute TB ##
################

my_vunit.main()
