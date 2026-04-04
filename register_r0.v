`timescale 1ns/10ps

// Edge-triggered parameterized register module specifically modified for Register 0.
// Handles base-addressing by forcing a zero output when BAout is asserted.
module register_r0 #(parameter size = 32)(
    output [size-1:0] busMuxIn,  // Data wire feeding the register stored value back into the main Bus
    input  [size-1:0] busMuxOut, // Data wire capturing the current value broadcast on the main Bus
    input  clr,                  // Synchronous clear signal driven by the Control Unit
    input  clock,                // System clock signal driving the synchronous logic
    input  Rin,                  // Register input enable signal driven by the Select and Encode logic
    input  BAout                 // Base Address Out control signal driven by the Control Unit
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

    // Asynchronous output routing
    // If BAout is high, forcefully output zero for base-addressing calculations
    // Otherwise, continuously drive the stored value out to the bus multiplexer connection
    assign busMuxIn = BAout ? {size{1'b0}} : Q;

endmodule