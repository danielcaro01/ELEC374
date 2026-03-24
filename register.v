`timescale 1ns/10ps

module register #(parameter size = 32)(
    output [size-1:0] busMuxIn,
    input  [size-1:0] busMuxOut,
    input  clr, clock, Rin
);
    reg [size-1:0] Q;

    always @(posedge clock) begin
        if (clr) 
            Q <= 32'b0;
        else if (Rin) 
            Q <= busMuxOut;
    end

    assign busMuxIn = Q;

endmodule