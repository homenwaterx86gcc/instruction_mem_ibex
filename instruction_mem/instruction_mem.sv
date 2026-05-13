module instruction_mem #(
    parameter WIDTH = 32,
    parameter DEPTH_BRAM = 1024
)(
    input logic instr_req_i,
    input logic [WIDTH - 1 : 0] instr_addr_i,
    output logic instr_rvalid_o,
    output logic instr_gnt_o,
    output logic [WIDTH -1 : 0] instr_rdata_o,
    output logic [6 : 0] instr_rdata_intg_o,
    output logic instr_err_o,
    input logic clk_i,
    input logic rst_i
);

logic we_sig;

assign we_sig = ~instr_req_i;
assign instr_rvalid_o = 1'b1;
assign instr_gnt_o = 1'b1;
assign instr_err_o = 1'b0;
assign instr_rdata_intg_o = '0;


block_ram #(
    .DATA_WIDTH(WIDTH),
    .ADDR_WIDTH(WIDTH),
    .DEPTH_MEM(DEPTH_BRAM)
)bram (
    .clk(clk_i),
    .we(we_sig),
    .addr(instr_addr_i),
    .data_i('0),
    .data_o(instr_rdata_o)
);



endmodule

