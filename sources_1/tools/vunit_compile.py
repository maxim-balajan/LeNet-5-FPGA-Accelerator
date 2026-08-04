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

"""
    Small Python file enabling compilation of entire VHDL code base for
    correctly initializing VHDL-LS utilized by TerosHDL...
"""

from os import environ
from os.path import join, abspath


# import VUnit and project specific libraries
from vunit import VUnit


# basic setup
source_path = abspath(environ["PRJ_HW_SOURCES_PATH"])

# TB setup

my_vunit = VUnit.from_argv()
my_vunit.add_vhdl_builtins()


my_vunit.add_osvvm()
my_vunit.add_verification_components()


#############
# setup TB ##
#############

tb_lib = my_vunit.add_library("tb_lib", vhdl_standard="2008")
tb_lib.add_source_files(join(source_path, "**", "src", "*.vhd"))
tb_lib.add_source_files(join(source_path, "**", "sim", "**", "testbench", "*.vhd"))
tb_lib.add_source_files(join(source_path, "memory", "*.vhd"))
#tb_lib.add_source_files(join(source_path, "*.vhd"))

################
## execute TB ##
################

my_vunit.main()
