# Resolve sources relative to this script, regardless of launch directory.
set script_dir [file dirname [file normalize [info script]]]
cd $script_dir
onerror {quit -code 1}
vlib work
vlog +define+SIM +cover -covercells \
    ../rtl/FIFO_shared.sv \
    ../rtl/shared_pkg.sv \
    ../tb/FIFO_transaction.sv \
    ../tb/FIFO_scoreboard.sv \
    ../tb/FIFO_coverage.sv \
    ../rtl/FIFO_if.sv \
    ../rtl/FIFO.sv \
    ../tb/FIFO_tb.sv \
    ../tb/FIFO_monitor.sv \
    ../tb/FIFO_top.sv
vsim -voptargs=+acc work.FIFO_top -coverage
run 0
add wave *
run -all
coverage save FIFO_top.ucdb
