onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label src_clk -radix binary /tb_Complex_CDC/dut/src_clk
add wave -noupdate -label dest_clk -radix binary /tb_Complex_CDC/dut/dest_clk
add wave -noupdate -label dest_arstn -radix binary /tb_Complex_CDC/dut/dest_arstn
add wave -noupdate -label src_arstn -radix binary /tb_Complex_CDC/dut/src_arstn
add wave -noupdate -label src_sync1 -radix binary /tb_Complex_CDC/dut/src_sync1
add wave -noupdate -label src_sync2 -radix binary /tb_Complex_CDC/dut/src_sync2
add wave -noupdate -label src_sync3 -radix binary /tb_Complex_CDC/dut/src_sync3
add wave -noupdate -label handshake_src -radix binary /tb_Complex_CDC/dut/handshake_src
add wave -noupdate -label busy_src -radix binary /tb_Complex_CDC/dut/busy_src
add wave -noupdate -label dest_sync1 -radix binary /tb_Complex_CDC/dut/dest_sync1
add wave -noupdate -label dest_sync2 -radix binary /tb_Complex_CDC/dut/dest_sync2
add wave -noupdate -label dest_sync3 -radix binary /tb_Complex_CDC/dut/dest_sync3
add wave -noupdate -label en_dest -radix binary /tb_Complex_CDC/dut/en_dest
add wave -noupdate -label handshake_dest -radix binary /tb_Complex_CDC/dut/handshake_dest
add wave -noupdate -label src_data -radix binary /tb_Complex_CDC/dut/src_data
add wave -noupdate -label dest_data -radix binary /tb_Complex_CDC/dut/dest_data
add wave -noupdate -label ff_src -radix binary /tb_Complex_CDC/dut/ff_src
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82808 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 284
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {635250 ps}
