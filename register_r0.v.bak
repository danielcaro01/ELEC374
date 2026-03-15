`timescale 1ns/10ps

module register_r0 #(parameter size = 32)( 
    output [size-1:0] busMuxIn,
    input [size-1:0] busMuxOut,
    input clr, clock, Rin, BAout 
); 
    reg [size-1:0] Q;
    
    always @(posedge clock or posedge clr) begin
        if (clr) begin
            Q <= 0;
        end else if (Rin) begin
            Q <= busMuxOut;
        end
    end
    
    // If BAout is high, gate 0s onto the bus; otherwise output Q
    assign busMuxIn = BAout ? 32'b0 : Q;
endmodule