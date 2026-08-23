onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -itemcolor Green /tb_i2c/clock
add wave -noupdate -color Magenta -itemcolor White -label {DATA RECEBIDO} /tb_i2c/uut/fsm_inst/Data
add wave -noupdate -color Magenta -itemcolor White -label DISPLAY /tb_i2c/display
add wave -noupdate -itemcolor Green -label LED /tb_i2c/Led
add wave -noupdate -color Cyan -itemcolor Cyan /tb_i2c/SCL
add wave -noupdate -color Gold -itemcolor Yellow /tb_i2c/SDA
add wave -noupdate -color Coral -itemcolor White -label ENDEREÇO -radix hexadecimal /tb_i2c/uut2/addr_ptr
add wave -noupdate -color Coral -itemcolor White -label {INDICE DA MEMORIA} -radix binary /tb_i2c/uut2/index
add wave -noupdate -label {ESTADO DA EEPROM} -radix unsigned /tb_i2c/uut2/state
add wave -noupdate -label {ESTADO DA FSM} -radix unsigned /tb_i2c/uut/fsm_inst/current_state
add wave -noupdate -color Red -itemcolor White -label {ACK MESTRE} /tb_i2c/uut/fsm_inst/ack
add wave -noupdate -label RW /tb_i2c/uut2/rw_bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {598975705 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {882052500 ps}
