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

# create virtual clock for OOC synthesis
# ---------------------------------------

create_clock -period 2.0 [get_ports clk]

# constraint input and output delays
# ----------------------------------

set delay_tolerance 0.1

set main_clock [get_clocks -of_objects [get_ports clk]]
set period_main_clk [get_property PERIOD $main_clock]
set clock_delay [expr { $period_main_clk * $delay_tolerance }]

# reset delay
set_input_delay -clock $main_clock $clock_delay [get_ports reset]
 
# output delay
set_output_delay -clock $main_clock $clock_delay [get_ports o_* -filter {DIRECTION == OUT}]

# input delay
set_input_delay -clock $main_clock $clock_delay [get_ports i_* -filter {DIRECTION == IN}]
