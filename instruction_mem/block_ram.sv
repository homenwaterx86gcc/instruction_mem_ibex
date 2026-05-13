module block_ram #(
parameter DATA_WIDTH=32,
parameter ADDR_WIDTH=32,
parameter DEPTH_MEM = 1024
)(
    input wire we,
    input wire clk,
    input wire [DATA_WIDTH-1:0] data_i,
    input wire [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] data_o
);
    localparam WORD = (DATA_WIDTH-1);
    localparam DEPTH = (DEPTH_MEM); //fürs erste
    reg [WORD:0] memory [0:DEPTH];
    always @(posedge clk) begin
        if (we)
            memory[addr] <= data_i;
        else data_o <= memory[addr];
        end
endmodule