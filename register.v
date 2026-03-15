module register #(parameter size = 32)( 
    output [size-1:0] busMuxIn, // Added bit range
    input [size-1:0] busMuxOut, // Added bit range
    input clr, clock, Rin 
); 
    reg [size-1:0] Q;
    
    always @(posedge clock or posedge clr) begin
        if (clr) begin
            Q <= 0;
        end else if (Rin) begin
            Q <= busMuxOut;
        end
    end
    
    assign busMuxIn = Q;
endmodule