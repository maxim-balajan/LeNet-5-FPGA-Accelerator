onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label {clk} -expand /comparator_tree_tb/s_tb_i.clk
add wave -noupdate -label {reset} -expand /comparator_tree_tb/s_tb_o.reset
add wave -noupdate -label {TB_I RECORD} -expand /comparator_tree_tb/s_tb_i
add wave -noupdate -label {TB_O RECORD} -expand /comparator_tree_tb/s_tb_o
update
vunit_restart
wave zoom full
