`timescale 1ns/10ps

module DataPath (
    input clk, clr,
    
    // Register load controls
    input R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in,
    input HIin, LOin, MDRin, IRin, Yin, Zin, MARin, PCin,
    
    // Bus & Memory controls
    input Read,
    input [31:0] Mdatain,
    input [4:0] BusMuxSel,
    
    // ALU Control Signals
    input AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op,
    input SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op,
    input IncPC
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
    assign Zlowout = Zout[31:0];
    
    wire [31:0] InPort = 32'h0;
    wire [31:0] C_sign_ext = 32'h0;

    // Registers
    register R0 (R0out, BusMuxOut, clr, clk, R0in);
    register R1 (R1out, BusMuxOut, clr, clk, R1in);
    register R2 (R2out, BusMuxOut, clr, clk, R2in);
    register R3 (R3out, BusMuxOut, clr, clk, R3in);
    register R4 (R4out, BusMuxOut, clr, clk, R4in);
    register R5 (R5out, BusMuxOut, clr, clk, R5in);
    register R6 (R6out, BusMuxOut, clr, clk, R6in);
    register R7 (R7out, BusMuxOut, clr, clk, R7in);
    register R8 (R8out, BusMuxOut, clr, clk, 1'b0); 
    register R9 (R9out, BusMuxOut, clr, clk, 1'b0);  
    register R10 (R10out, BusMuxOut, clr, clk, 1'b0);
    register R11 (R11out, BusMuxOut, clr, clk, 1'b0);
    register R12 (R12out, BusMuxOut, clr, clk, 1'b0);
    register R13 (R13out, BusMuxOut, clr, clk, 1'b0);
    register R14 (R14out, BusMuxOut, clr, clk, 1'b0);
    register R15 (R15out, BusMuxOut, clr, clk, 1'b0);
    register HI (HIout, BusMuxOut, clr, clk, HIin);
    register LO (LOout, BusMuxOut, clr, clk, LOin);
    register PC (PCout, BusMuxOut, clr, clk, PCin);
    register IR (IRout, BusMuxOut, clr, clk, IRin);
    register Y (Yout, BusMuxOut, clr, clk, Yin);
    register MAR(MARout, BusMuxOut, clr, clk, MARin);

    MDR mdr_unit (MDRout, Mdatain, BusMuxOut, Read, clr, clk, MDRin);

    wire [63:0] Znext;
    
    // ALU Instantiation mapped directly to BusMuxOut and Yout
    alu alu_unit (
        .Y(Yout), 
        .Bus(BusMuxOut), 
        .PC(PCout), 
        .AND_op(AND_op), .OR_op(OR_op), .NOT_op(NOT_op), .NEG_op(NEG_op),
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op),
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op), .ROR_op(ROR_op),
        .ROL_op(ROL_op), .IncPC_op(IncPC),
        .Z_next(Znext)
    );

    register #(.size(64)) Z (Zout, Znext, clr, clk, Zin);

    bus main_bus (
        BusMuxOut, BusMuxSel,
        R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, 
        R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
        HIout, LOout, Zhighout, Zlowout,
        PCout, MDRout, InPort, C_sign_ext
    );

endmodule




//old datapath file
/*module DataPath (input clk, clr, R0in, R1in, R2in, Mdatain, BusMuxSel);
	wire [31:0] BusMuxOut, BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7, BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15, BusMuxInHI, BusMuxInLO, BusMuxInZhigh, BusMuxInZlow, BusMuxInPC, BusMuxInMDR, BusMuxInInport, BusMuxInCsignext;
	wire [4:0] BusMuxSel;
	
	register R0 (BusMuxInR0, BusMuxOut, clr, clk, R0in);
	register R1 (BusMuxInR1, BusMuxOut, clr, clk, R1in);
	register R2 (BusMuxInR2, BusMuxOut, clr, clk, R2in);
	
	Bus bus (BusMuxOut, BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7, BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15, BusMuxInHI, BusMuxInLO, BusMuxInZhigh, BusMuxInZlow, BusMuxInPC, BusMuxInMDR, BusMuxInInport, BusMuxInCsignext, BusMuxSel);
endmodule;*/
	