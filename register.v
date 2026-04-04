`timescale 1ns/10ps

// Edge-triggered parameterized register module for the CPU Datapath.
// Captures data from the main bus and holds it securely for subsequent operations.
module register #(parameter size = 32)(
    output [size-1:0] busMuxIn,  // Data wire feeding the register's stored value back into the main Bus
    input  [size-1:0] busMuxOut, // Data wire capturing the current value broadcast on the main Bus
    input  clr,                  // Synchronous clear signal driven by the Control Unit
    input  clock,                // System clock signal driving the synchronous logic
    input  Rin                   // Register input enable signal driven by the Select and Encode logic
);

    // Internal storage element sized dynamically based on the instantiation parameter
    reg [size-1:0] Q;

    // Synchronous evaluation block triggered exclusively on the rising edge of the clock
    always @(posedge clock) begin
        
        // Priority evaluation for the clear signal to safely wipe the register contents
        if (clr) begin
            Q <= {size{1'b0}};
        end
        
        // If clear is low and the write-enable signal is asserted, latch the incoming bus data
        else if (Rin) begin
            Q <= busMuxOut;
        end
        
    end

    // Continuously drive the stored value out to the bus multiplexer connection
    assign busMuxIn = Q;

endmodule