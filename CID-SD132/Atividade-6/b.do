.main clear
project compileall
vsim  -onfinish stop -c -gui work.tb_maq_refri_206;
add wave -position insertpoint sim:/tb_maq_refri_206/*
view wave
run -all
wave zoom full

