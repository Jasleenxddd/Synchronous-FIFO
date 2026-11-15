vlib work
vlog *v +define+SIM  +cover -covercells 
vsim -voptargs=+acc work.FIFO_top -cover
run 0
add wave *
coverage save FIFO_top.ucdb 
run -all
