
module DataPath (
    input clk, clr, 
    input R0in, R1in, R2in, R5in, R6in, MDRin, // 3-8
    input Read,                               // 9
    input [31:0] Mdatain,                     // 10
    input [4:0] BusMuxSel,                    // 11
    input IRin, Yin, Zin, MARin, PCin,        // 12-16
    input AND, IncPC                          // 17-18
);
    // Bus and register wires
    wire [31:0] BusMuxOut;

    wire [31:0] R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    wire [31:0] R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    wire [31:0] HIout, LOout;
    wire [31:0] PCout, MDRout, IRout, Yout, MARout;
    wire [63:0] Zout;
    wire [31:0] Zhighout, Zlowout;

    assign Zhighout = Zout[63:32];
    assign Zlowout  = Zout[31:0];

    // Unused sources for Phase 1 TB
    wire [31:0] InPort = 32'h0;
    wire [31:0] C_sign_ext = 32'h0;

    // ===== Registers =====
    register R0 (R0out, BusMuxOut, clr, clk, R0in);
    register R1 (R1out, BusMuxOut, clr, clk, R1in);
    register R2 (R2out, BusMuxOut, clr, clk, R2in);
    register R3 (R3out, BusMuxOut, clr, clk, 1'b0);
    register R4 (R4out, BusMuxOut, clr, clk, 1'b0);
    register R5 (R5out, BusMuxOut, clr, clk, R5in);
    register R6 (R6out, BusMuxOut, clr, clk, R6in);
    register R7 (R7out, BusMuxOut, clr, clk, 1'b0);

    register R8  (R8out,  BusMuxOut, clr, clk, 1'b0);
    register R9  (R9out,  BusMuxOut, clr, clk, 1'b0);
    register R10 (R10out, BusMuxOut, clr, clk, 1'b0);
    register R11 (R11out, BusMuxOut, clr, clk, 1'b0);
    register R12 (R12out, BusMuxOut, clr, clk, 1'b0);
    register R13 (R13out, BusMuxOut, clr, clk, 1'b0);
    register R14 (R14out, BusMuxOut, clr, clk, 1'b0);
    register R15 (R15out, BusMuxOut, clr, clk, 1'b0);

    register HI (HIout, BusMuxOut, clr, clk, 1'b0);
    register LO (LOout, BusMuxOut, clr, clk, 1'b0);

    register PC (PCout, BusMuxOut, clr, clk, PCin);
    register IR (IRout, BusMuxOut, clr, clk, IRin);
    register Y  (Yout,  BusMuxOut, clr, clk, Yin);
    register MAR(MARout,BusMuxOut, clr, clk, MARin);

    // MDR (two-input mux inside)
    MDR mdr_unit (MDRout, Mdatain, BusMuxOut, Read, clr, clk, MDRin);

    // ===== Minimal ALU for Phase-1 TB (AND + IncPC) =====
    wire [63:0] Znext;
    alu32_min alu0(.y(Yout), .bus(BusMuxOut), .AND_op(AND), .IncPC_op(IncPC), .pc(PCout), .z_next(Znext));

    // 64-bit Z register (Zin controls write)
    register #(.size(64)) Z (Zout, Znext, clr, clk, Zin);

    // ===== Bus Mux =====
    bus main_bus (
        BusMuxOut, BusMuxSel, 
        R0out, R1out, R2out, R3out, R4out, 
        R5out, R6out, R7out, R8out, R9out, 
        R10out, R11out, R12out, R13out, R14out, R15out,
        HIout, LOout, Zhighout, Zlowout,
        PCout, MDRout, InPort, C_sign_ext
    );

endmodule
