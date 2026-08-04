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
    Small little script to generate command prompt files
    for the surfer waveviewer. Currently only Record signals 
    and clk/reset are added...
"""


def create_surfer_cmd_script(tb_name: str, output_path: str, use_resetn: bool=False):
    with open(output_path, "w") as f:
        # add clk
        print(f"variable_add {tb_name}.clk", file=f)
        print(f"item_focus a_{tb_name}.clk", file=f)
        print(f"item_rename clk", file=f)
        # add reset(n)
        if use_resetn:
            print(f"variable_add {tb_name}.s_tb_o.resetn", file=f)
            print(f"item_focus b_resetn")
            print(f"item_rename resetn", file=f)
        else:
            print(f"variable_add {tb_name}.s_tb_o.reset", file=f)
            print(f"item_rename reset", file=f)
        # To correctly rename the record groups this has to be written like this...
        print(f"scope_add_as_group {tb_name}.s_tb_i", file=f)
        print(f"group_fold_all", file=f)
        print(f"item_unfocus", file=f)
        print(f"scope_add_as_group {tb_name}.s_tb_o", file=f)
        print(f"group_fold_all", file=f)
        print(f"item_focus c_s_tb_i", file=f)
        print(f"item_rename TB_I", file=f)
        print(f"item_focus d_s_tb_o", file=f)
        print(f"item_rename TB_O", file=f)
        print(f"group_unfold_all", file=f)
        print("zoom_fit", file=f)


"""
    Small little script to generate command prompt files
    for ModelSim. Currently only Record signals 
    and clk/reset are added...
"""


def create_modelsim_do_script(tb_name: str, output_path: str, use_resetn: bool=False):
    with open(output_path, "w") as f:
        # add clk
        print("onerror {resume}", file=f)
        print("quietly WaveActivateNextPane {} 0", file=f)
        print(f"add wave -noupdate -label {{clk}} -expand /{tb_name}/s_tb_i.clk", file=f)
        if use_resetn:
            print(f"add wave -noupdate -label {{resetn}} -expand /{tb_name}/s_tb_o.resetn", file=f)
        else:
            print(f"add wave -noupdate -label {{reset}} -expand /{tb_name}/s_tb_o.reset", file=f)
        print(f"add wave -noupdate -label {{TB_I RECORD}} -expand /{tb_name}/s_tb_i", file=f)
        print(f"add wave -noupdate -label {{TB_O RECORD}} -expand /{tb_name}/s_tb_o", file=f)
        print(f"update", file=f)
        print(f"vunit_restart", file=f)
        print(f"wave zoom full", file=f)