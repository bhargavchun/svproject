# Compile the design files and testbench
vlib work
vlog -lint APB_RAM_DESIGN.sv +acc
vlog -lint APB_RAM_MUL_SLAVE.sv +acc
vlog -lint APB_RAM_MUL_SLAVE_TB.sv +acc
vlog -lint APB_RAM_SLAVE.sv +acc
vlog -lint proj_package.sv +acc
vlog -lint self_check.sv +acc
vlog -lint sv_inter.sv +acc

# Simulate the testbench
vsim work.tb_mul_slave

# Source the wave-related do files
 
add wave -group "APB_Master" sim:/tb_mul_slave/dut/m1/*
add wave -group "APB_Slave 1" sim:/tb_mul_slave/dut/s1/*
add wave -group "APB_Slave 2" sim:/tb_mul_slave/dut/s2/*

run -all               

    
