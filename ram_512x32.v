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

    // ASYNCHRONOUS READ: Data outputs instantly when Read == 1
    always @(*) begin
        if (Read) 
            DataOut = memory[Address];
        else 
            DataOut = 32'hZ; 
    end

    // SYNCHRONOUS WRITE: Data writes strictly on the clock edge
    always @(posedge clk) begin
        if (Write)
            memory[Address] <= DataIn;
    end
endmodule