.main clear
project compileall
vsim  -onfinish stop -gui work.tb_maq_refri_206;;
add wave -position insertpoint sim:/tb_maq_refri_206/*
run -all