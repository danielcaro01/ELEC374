`timescale 1ns/10ps

// Memory Data Register handles data moving between the CPU Bus and the Memory Subsystem
module MDR (
    output [31:0] MDRout,      // Output data wire feeding the main bus or memory DataIn
    input  [31:0] Mdatain,     // Input data wire bringing data from the RAM module
    input  [31:0] busMuxOut,   // Input data wire capturing data from the main processor bus
    input  Read,               // Control signal routing memory data into the register when high
    input  clr,                // Synchronous clear signal to reset the register
    input  clock,              // System clock signal driving synchronous logic
    input  MDRin               // Enable signal to latch incoming data
);

    // Internal wire for the 2-to-1 multiplexer routing
    wire [31:0] MDMux_out;
    
    // Internal storage element for the register
    reg [31:0] Q;

    // 2-to-1 Multiplexer selects Mdatain when Read is asserted, otherwise routes the main bus
    assign MDMux_out = Read ? Mdatain : busMuxOut;

    // Synchronous register evaluation block triggered on the rising edge
    always @(posedge clock) begin
        
        // Priority evaluation for the clear signal to wipe the register
        if (clr) begin
            Q <= 32'b0;
        end
        
        // Latch the multiplexer output when the write enable signal is asserted
        else if (MDRin) begin
            Q <= MDMux_out;
        end
        
    end

    // Continuously drive the stored value out to the MDRout port
    assign MDRout = Q;

endmodule