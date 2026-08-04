onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label {clk} -expand /lenet_accel_tb/s_tb_i.clk
add wave -noupdate -label {reset} -expand /lenet_accel_tb/s_tb_o.reset
add wave -noupdate -label {TB_I RECORD} -expand /lenet_accel_tb/s_tb_i
add wave -noupdate -label {TB_O RECORD} -expand /lenet_accel_tb/s_tb_o
update
vunit_restart
wave zoom full
