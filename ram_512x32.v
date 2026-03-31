`timescale 1ns/10ps
module ram_512x32 (
    input clk,
    input Read,
    input Write,
    input [8:0] Address,
    input [31:0] DataIn,
    output reg [31:0] DataOut
);

    reg [31:0] memory [0:511];

    // Synchronous Write Logic
    always @(posedge clk) begin
        if (Write == 1'b1) begin
            memory[Address] <= DataIn;
        end
    end

    // Combinational Read Logic ensures data is instantly available to the MDR
    always @(*) begin
        if (Read == 1'b1) begin
            DataOut = memory[Address];
        end else begin
            DataOut = 32'h00000000; 
        end
    end

endmodule