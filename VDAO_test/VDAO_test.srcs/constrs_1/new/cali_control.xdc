set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property PACKAGE_PIN N15 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN N16 [get_ports EN_cali]
set_property PACKAGE_PIN T17 [get_ports EN_trans]
set_property IOSTANDARD LVCMOS33 [get_ports EN_trans]
set_property IOSTANDARD LVCMOS33 [get_ports EN_cali]

set_operating_conditions -grade extended


set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
