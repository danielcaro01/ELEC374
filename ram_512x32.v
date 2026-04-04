`timescale 1ns/10ps

// Synchronous RAM module for the Memory Subsystem
// Stores the machine code program and execution data for the Datapath
module ram_512x32 (
    input clk,
    input Read,                 // Control signal asserted by the CU to read from memory
    input Write,                // Control signal asserted by the CU to write to memory
    input [8:0] Address,        // 9-bit address bus explicitly sized to access 512 memory locations
    input [31:0] DataIn,        // 32-bit data input bus driven by the MDR during store instructions
    output reg [31:0] DataOut   // 32-bit data output bus routed to the MDR during load and fetch instructions
);

    // Explicit declaration of the 512-word by 32-bit memory array
    reg [31:0] memory [0:511];

    // Synchronous memory access evaluated strictly on the positive edge of the clock
    always @(posedge clk) begin
        
        // Write operation: Stores data into the specified memory address when Write is high
        if (Write) begin
            memory[Address] <= DataIn;
        end
        
        // Read operation: Retrieves data from the specified memory address when Read is high
        if (Read) begin
            DataOut <= memory[Address];
        end
        
    end

endmodule