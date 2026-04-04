// encoder_32to5.v

`timescale 1ns/10ps

// 32-to-5 Encoder for the CPU Datapath Bus Multiplexer
// Evaluates the active output enable control signals and generates a 5-bit selection code
// to route the appropriate register's contents onto the main 32-bit Datapath bus.
module encoder_32to5 (
    input [15:0] R_out,        // Output enable signals for the 16 General Purpose Registers
    input HIout, LOout,        // Output enable signals for the HI and LO special registers
    input Zhighout, Zlowout,   // Output enable signals for the Z ALU result registers
    input PCout,               // Output enable signal for the Program Counter
    input MDRout,              // Output enable signal for the Memory Data Register
    input InPortout,           // Output enable signal for the Hardware Input Port
    input Cout,                // Output enable signal for the Sign-Extended Constant
    output reg [4:0] sel       // 5-bit selection code driving the 32-to-1 Bus Multiplexer
);

    // Combinational logic block to decode the one-hot control signals
    always @(*) begin
        
        // Default assignment absolutely prevents inferred latches and defaults to R0
        sel = 5'd0;

        // Encode General Purpose Registers (R0 to R15)
        if (R_out)       sel = 5'd0;
        else if (R_out[1])  sel = 5'd1;
        else if (R_out[2])  sel = 5'd2;
        else if (R_out[3])  sel = 5'd3;
        else if (R_out[4])  sel = 5'd4;
        else if (R_out[5])  sel = 5'd5;
        else if (R_out[6])  sel = 5'd6;
        else if (R_out[7])  sel = 5'd7;
        else if (R_out[8])  sel = 5'd8;
        else if (R_out[9])  sel = 5'd9;
        else if (R_out[10]) sel = 5'd10;
        else if (R_out[11]) sel = 5'd11;
        else if (R_out[12]) sel = 5'd12;
        else if (R_out[13]) sel = 5'd13;
        else if (R_out[14]) sel = 5'd14;
        else if (R_out[15]) sel = 5'd15;

        // Encode Special Purpose Registers and System I/O
        else if (HIout)     sel = 5'd16;
        else if (LOout)     sel = 5'd17;
        else if (Zhighout)  sel = 5'd18;
        else if (Zlowout)   sel = 5'd19;
        else if (PCout)     sel = 5'd20;
        else if (MDRout)    sel = 5'd21;
        else if (InPortout) sel = 5'd22;
        else if (Cout)      sel = 5'd23;
        
    end

endmodule
