onerror {quit -f}
vlib work
vlog -work work zadanie.vo
vlog -work work zadanie.vt
vsim -novopt -c -t 1ps -L cycloneive_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.zadanie_vlg_vec_tst
vcd file -direction zadanie.msim.vcd
vcd add -internal zadanie_vlg_vec_tst/*
vcd add -internal zadanie_vlg_vec_tst/i1/*
add wave /*
run -all
