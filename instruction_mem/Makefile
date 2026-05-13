#Makefile!
FPGA_DEVICE = CCGM1A1
TOP = prim_ram_2p_adv
TOP_TB = instruction_mem_tb
TESTBENCH = instruction_mem_tb.sv
INSTRUCTION_MEM = instruction_mem.sv
BLOCK_RAM = block_ram.sv
BITFILE = out.txt
BITSTREAM = bitfile.txt
TEST_BITSTREAM = blinky_test.bit
DUAL_BLOCK_RAM = dual_port_block_ram.sv
DUAL_BLOCK_RAM_REAL = dual_port_block_ram_real.sv
PATH_OPENFPGALOADER = /home/furz1000/olimex-gatemate/oss-cad-suite/bin/openFPGALoader 
synthesize:
	yosys -ql synth_log.txt -p "read_verilog -defer -sv $(DUAL_BLOCK_RAM) $(DUAL_BLOCK_RAM_REAL); synth_gatemate -top $(TOP) -luttree -nomx8; write_json $(TOP)_netlist.json; write_verilog $(TOP)_netlist.v"

schematic:
	yosys -p "read_verilog -sv $(DUAL_BLOCK_RAM_REAL); synth; show -format png -prefix schematic"


simulation:
	verilator --binary --trace --sv $(INSTRUCTION_MEM) $(TESTBENCH) --top $(TOP_TB)
	./obj_dir/V($TESTBENCH)
	gtkwave wave.vcd

gui_implement:
	nextpnr-himbaechel --device=$(FPGA_DEVICE) --gui

implement:
	nextpnr-himbaechel --device=$(FPGA_DEVICE) --vopt allow-unconstrained --json $(TOP)_netlist.json -o out=out.txt --router router2

bitstream:
	gmpack $(BITFILE) $(BITSTREAM)


flash:
	sudo $(PATH_OPENFPGALOADER) -c dirtyJtag $(TEST_BITSTREAM)
#olimex_gatemateevb         dirtyJtag          GM1A1                    
#gatemate_evb_spi         0x0403:6010
#/home/furz1000/olimex-gatemate/oss-cad-suite/bin
# sudo /home/furz1000/olimex-gatemate/oss-cad-suite/bin/openFPGALoader -c dirtyJtag blinky_test.bit
clean:
	rm $(TOP)_netlist.json synth_log.txt schematic.png wave.vcd *.json *.log