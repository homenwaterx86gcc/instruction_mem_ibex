// Dual Port RAM (NO_CHANGE)
//Hier aus dem primitive pdf: (Xaver)
/*
module bram_dp_no_change #(
    parameter DATA_WIDTH=18,
    parameter ADDR_WIDTH=9,
    parameter DEPTH_MEM
    )(
    input wire wea,
    input wire web,
    input wire clka,
    input wire clkb,
    input wire [DATA_WIDTH-1:0] dia,
    input wire [DATA_WIDTH-1:0] dib,
    input wire [ADDR_WIDTH-1:0] addra,
    input wire [ADDR_WIDTH-1:0] addrb,
    output reg [DATA_WIDTH-1:0] doa,
    output reg [DATA_WIDTH-1:0] dob
    );
    localparam WORD = (DATA_WIDTH-1);
    localparam DEPTH = (DEPTH_MEM);
    reg [WORD:0] memory [0:DEPTH];
    initial $readmemb("mem/mem_a9d18.hex", memory); // optional
    always @(posedge clka) begin
    if (wea) begin
    memory[addra] <= dia;
    end else
    doa <= memory[addra];
    end
    always @(posedge clkb) begin
    if (web) begin
    memory[addrb] <= dib;
    end else
    dob <= memory[addrb];
    end
    endmodule
*/

//So sieht die instanzierung aus: (Xaver)
/*  // SRAM block for instruction and data storage
  ram_2p #(
      .Depth(1024*1024/4),
      .BExtraDelay(`INSTR_CYCLE_DELAY),
      .MemInitFile(SRAMInitFile)
    ) u_ram (
      .clk_i       (clk_sys),
      .rst_ni      (rst_sys_n),

      .a_req_i     (device_req[Ram]),
      .a_we_i      (device_we[Ram]),
      .a_be_i      (device_be[Ram]),
      .a_addr_i    (device_addr[Ram]),
      .a_wdata_i   (device_wdata[Ram]),
      .a_rvalid_o  (device_rvalid[Ram]),
      .a_rdata_o   (device_rdata[Ram]),

      .b_req_i     (instr_req),
      .b_we_i      (1'b0),
      .b_be_i      (4'b0),
      .b_addr_i    (instr_addr),
      .b_wdata_i   (32'b0),
      .b_rvalid_o  (instr_rvalid),
      .b_rdata_o   (instr_rdata)
    );
*/
//hier steht eig: moudle prim_ram_2p_async_adv import prim_ram_2p_pkg::*(;
//aber ich glaube wir brauchen dieses package nicht... (Xaver)
module prim_ram_2p_async_adv #(
  parameter  int Depth                = 1024,//davor 512 aber wird eh überschrieben (Xaver)
  parameter  int Width                = 32,
  parameter  int DataBitsPerMask      = 1,  // Number of data bits per bit of write mask
  parameter      MemInitFile          = "", // VMEM file to initialize the memory with
  // Configurations
  parameter  bit EnableECC            = 0, // Enables per-word ECC
  parameter  bit EnableParity         = 0, // Enables per-Byte Parity
  parameter  bit EnableInputPipeline  = 0, // Adds an input register (read latency +1)
  parameter  bit EnableOutputPipeline = 0, // Adds an output register (read latency +1)

  // This switch allows to switch to standard Hamming ECC instead of the HSIAO ECC.
  // It is recommended to leave this parameter at its default setting (HSIAO),
  // since this results in a more compact and faster implementation.
  parameter bit HammingECC            = 0,
        //davor localparam int Aw = prim_util_pkg::vibits(Depth)
  //ersetze ich durch die 32 bits einfach
  localparam int Aw                   = 32
) (
  input clk_a_i,
  input clk_b_i,
  input rst_a_ni,
  input rst_b_ni,

  input                    a_req_i,
  input                    a_write_i,
  input        [Aw-1:0]    a_addr_i,
  input        [Width-1:0] a_wdata_i,
  input        [Width-1:0] a_wmask_i,  // cannot be used with ECC, tie to 1 in that case
  output logic [Width-1:0] a_rdata_o,
  output logic             a_rvalid_o, // read response (a_rdata_o) is valid
  output logic [1:0]       a_rerror_o, // Bit1: Uncorrectable, Bit0: Correctable

  input                    b_req_i,
  input                    b_write_i,
  input        [Aw-1:0]    b_addr_i,
  input        [Width-1:0] b_wdata_i,
  input        [Width-1:0] b_wmask_i,  // cannot be used with ECC, tie to 1 in that case
  output logic [Width-1:0] b_rdata_o,
  output logic             b_rvalid_o, // read response (b_rdata_o) is valid
  output logic [1:0]       b_rerror_o, // Bit1: Uncorrectable, Bit0: Correctable

  // config
  //input  ram_2p_cfg_t      cfg_i, //brauchen wir nicht
  //output ram_2p_cfg_rsp_t  cfg_rsp_o //brauchen wir nicht
);

localparam WORD = (Width-1);
localparam DEPTH_MEM = (Depth);
reg [WORD:0] memory [0:DEPTH_MEM];
//initial $readmemb("mem/mem_a9d18.hex", memory); // optional
always @(posedge clk_a_i) begin
    if (a_req_i) begin
        if(a_write_i) begin
            memory[a_addr_i] <= a_wdata_i;
        end
        else begin
            a_rdata_o <= memory[a_addr_i];
        end
    end
end

always @(posedge clk_b_i) begin
    if (b_req_i) begin
        if(b_write_i) begin
            memory[b_addr_i] <= b_wdata_i;
        end
        else begin
            b_rdata_o <= memory[b_addr_i];
        end
    end
end

endmodule
