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

from os import environ
from os.path import join, dirname, abspath, isfile
import sys

source_path = abspath(environ["PRJ_HW_SOURCES_PATH"])
sys.path.append(source_path)
from tools.cmd_wave_gen import *


# import VUnit and project specific libraries
from vunit import VUnit


# basic setup
cur_path = dirname(__file__)
wave_path = join(cur_path, "default_wave.do")
vunit_path = abspath(environ["PRJ_VUNIT_PATH"])
C_TB_NAME = "comparator_tree_tb"

# add VUnit to the system path variable
#sys.path.append(join(vunit_path))
#sys.path.append(join(abspath(join(vunit_path, 'python_scripts'))))

# TB setup

my_vunit = VUnit.from_argv()
my_vunit.add_vhdl_builtins()


my_vunit.add_osvvm()
#my_vunit.add_verification_components()


#############
# setup TB ##
#############

tb_lib = my_vunit.add_library("tb_lib", vhdl_standard="2008")
tb_lib.add_source_files(join(cur_path, "..", "src", "*.vhd"))
tb_lib.add_source_files(join(cur_path, "testbench", "*.vhd"))

# add test bench configurations

test_bench = tb_lib.test_bench(C_TB_NAME)
test_bench.add_config(name="tb_cfg_5_8_5", generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=5, G_INIT_PIPELINE_STEPS=5, G_BIT_WIDTH=8))
test_bench.add_config(name="tb_cfg_5_11_5",generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=5, G_INIT_PIPELINE_STEPS=5, G_BIT_WIDTH=11))
test_bench.add_config(name="tb_cfg_5_8_1", generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=5, G_INIT_PIPELINE_STEPS=1, G_BIT_WIDTH=8))
test_bench.add_config(name="tb_cfg_5_11_1",generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=5, G_INIT_PIPELINE_STEPS=1, G_BIT_WIDTH=11))
test_bench.add_config(name="tb_cfg_8_8_5",  generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=8, G_INIT_PIPELINE_STEPS=5, G_BIT_WIDTH=8))
test_bench.add_config(name="tb_cfg_8_11_5", generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=8, G_INIT_PIPELINE_STEPS=5, G_BIT_WIDTH=11))
test_bench.add_config(name="tb_cfg_8_8_1",  generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=8, G_INIT_PIPELINE_STEPS=1, G_BIT_WIDTH=8))
test_bench.add_config(name="tb_cfg_8_11_1", generics=dict(G_CONTROL_AMOUNT=10, G_INPUT_AMOUNT=8, G_INIT_PIPELINE_STEPS=1, G_BIT_WIDTH=11))

# Helper function to create surfer cmd file
#create_surfer_cmd_script(C_TB_NAME, output_path=wave_path)

# Helper function to create modelsim do file
create_modelsim_do_script(C_TB_NAME, wave_path)

################
## execute TB ##
################

my_vunit.main()
