transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/register.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/DataPath.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/Bus.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/MDR.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/ALU.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/ram_512x32.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/select_encode_logic.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/encoder_32to5.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/register_r0.v}
vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/con_ff_logic.v}

vlog -vlog01compat -work work +incdir+C:/Users/20djc12/ELEC374 {C:/Users/20djc12/ELEC374/tb_io.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_io

add wave *
view structure
view signals
run 500 ns
