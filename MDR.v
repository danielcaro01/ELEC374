`timescale 1ns/10ps
module MDR (
    output [31:0] MDRout,
    input  [31:0] Mdatain,
    input  [31:0] busMuxOut,
    input  Read, clr, clock, MDRin
);

    reg [31:0] Q;

    always @(posedge clock) begin
        if (clr == 1'b1) begin
            Q <= 32'h00000000;
        end
        else if (MDRin == 1'b1) begin
            // Multiplexer logic to select RAM data or Bus data based on Read signal
            if (Read == 1'b1) begin
                Q <= Mdatain;
            end
            else begin
                Q <= busMuxOut;
            end
        end
    end

    assign MDRout = Q;

endmodule