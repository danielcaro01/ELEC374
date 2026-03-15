`timescale 1ns/10ps

module ram_512x32 (
    input clk,
    input Read,
    input Write,
    input [8:0] Address,    // 9-bit address for 512 words
    input [31:0] DataIn,    // Data to be written from MDR
    output reg [31:0] DataOut // Data to be read into MDR
);
    // 512x32 Memory Array
    reg [31:0] memory [0:511];

    // Initialize memory for Phase 2 testing
    initial begin
        // You can uncomment the line below to load a hex file
        // $readmemh("memory_init.hex", memory);
        
        // Hardcoded initialization for Phase 2 Load and Store tests
        memory[8'h1F] = 32'h000000D4;
        memory[8'h65] = 32'h00000084; 
        memory[8'h82] = 32'h000000A7;
        memory[8'hC9] = 32'h0000002B;
    end

    // Synchronous Write
    always @(posedge clk) begin
        if (Write) begin
            memory[Address] <= DataIn;
        end
    end

    // Asynchronous Read
    always @(*) begin
        if (Read) begin
            DataOut = memory[Address];
        end else begin
            DataOut = 32'h00000000;
        end
    end
endmodule