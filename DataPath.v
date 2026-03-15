`timescale 1ns/10ps

module DataPath (
    input clk, clr,
    
    // Select and Encode Controls
    input Gra, Grb, Grc, Rin, Rout, BAout, Cout,
    
    // Branching and Condition Controls
    input CONin,
    output CON,
    
    // Input/Output Port Connections
    input [31:0] InPort_data_in,     // Data from external input device
    output [31:0] OutPort_data_out,  // Data to external output device
    input OutPortin,                 // Enable signal to write to Output Port
    
    // Other Register Controls
    input HIin, LOin, MDRin, IRin, Yin, Zin, MARin, PCin,
    
    // Bus Source Controls
    input HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout,
    
    // Memory controls
    input Read, Write,
    
    // ALU Control Signals
    input AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op,
    input SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op, IncPC
);

    // Internal Wires
    wire [31:0] BusMuxOut;
    wire [31:0] R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    wire [31:0] R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    wire [31:0] HIout_data, LOout_data, PCout_data, MDRout_data, IRout_data, Yout_data, MARout_data;
    wire [63:0] Zout_data;
    wire [31:0] Zhighout_data = Zout_data[63:32];
    wire [31:0] Zlowout_data = Zout_data[31:0];
    
    wire [31:0] InPort_data; // Now driven by the InPort register
    wire [31:0] RAM_DataOut;
    wire [31:0] C_sign_ext;
    wire [15:0] R_in, R_out;
    wire [4:0] BusMuxSel;

    // --- Input and Output Port Registers ---
    // InPort constantly samples external data on clock edge
    register InPortReg (
        .busMuxIn(InPort_data), 
        .busMuxOut(InPort_data_in), 
        .clr(clr), 
        .clock(clk), 
        .Rin(1'b1) 
    );

    // OutPort writes data from the bus when OutPortin is high
    register OutPortReg (
        .busMuxIn(OutPort_data_out), 
        .busMuxOut(BusMuxOut), 
        .clr(clr), 
        .clock(clk), 
        .Rin(OutPortin)
    );

    // --- CON FF Logic Instantiation ---
    con_ff_logic con_unit (
        .clk(clk), .CONin(CONin),
        .IR_C2(IRout_data[20:19]), .BusMuxOut(BusMuxOut), 
        .CON(CON)
    );

    // --- Select and Encode Subsystem ---
    select_encode_logic se_logic (
        .IR(IRout_data), 
        .Gra(Gra), .Grb(Grb), .Grc(Grc), 
        .Rin(Rin), .Rout(Rout), .BAout(BAout), 
        .R_in(R_in), .R_out(R_out), 
        .C_sign_ext(C_sign_ext)
    );

    encoder_32to5 bus_encoder (
        .R_out(R_out), 
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout), 
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        .sel(BusMuxSel)
    );

    // --- Registers ---
    register_r0 R0 (R0out, BusMuxOut, clr, clk, R_in, BAout);
    register R1 (R1out, BusMuxOut, clr, clk, R_in[1]);
    register R2 (R2out, BusMuxOut, clr, clk, R_in[2]);
    register R3 (R3out, BusMuxOut, clr, clk, R_in[3]);
    register R4 (R4out, BusMuxOut, clr, clk, R_in[4]);
    register R5 (R5out, BusMuxOut, clr, clk, R_in[5]);
    register R6 (R6out, BusMuxOut, clr, clk, R_in[6]);
    register R7 (R7out, BusMuxOut, clr, clk, R_in[7]);
    register R8 (R8out, BusMuxOut, clr, clk, R_in[8]); 
    register R9 (R9out, BusMuxOut, clr, clk, R_in[9]);  
    register R10 (R10out, BusMuxOut, clr, clk, R_in[10]);
    register R11 (R11out, BusMuxOut, clr, clk, R_in[11]);
    register R12 (R12out, BusMuxOut, clr, clk, R_in[12]);
    register R13 (R13out, BusMuxOut, clr, clk, R_in[13]);
    register R14 (R14out, BusMuxOut, clr, clk, R_in[14]);
    register R15 (R15out, BusMuxOut, clr, clk, R_in[15]);
    
    register HI (HIout_data, BusMuxOut, clr, clk, HIin);
    register LO (LOout_data, BusMuxOut, clr, clk, LOin);
    register PC (PCout_data, BusMuxOut, clr, clk, PCin);
    register IR (IRout_data, BusMuxOut, clr, clk, IRin);
    register Y (Yout_data, BusMuxOut, clr, clk, Yin);
    register MAR(MARout_data, BusMuxOut, clr, clk, MARin);

    // --- Memory Subsystem ---
    ram_512x32 main_memory (
        .clk(clk), .Read(Read), .Write(Write),
        .Address(MARout_data[8:0]), .DataIn(MDRout_data), .DataOut(RAM_DataOut) 
    );

    MDR mdr_unit (
        .MDRout(MDRout_data), .Mdatain(RAM_DataOut),
        .busMuxOut(BusMuxOut), .Read(Read), .clr(clr), .clock(clk), .MDRin(MDRin)
    );

    // --- ALU Subsystem ---
    wire [63:0] Znext;
    alu alu_unit (
        .Y(Yout_data), .Bus(BusMuxOut), .PC(PCout_data), 
        .AND_op(AND_op), .OR_op(OR_op), .NOT_op(NOT_op), .NEG_op(NEG_op),
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op),
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op), .ROR_op(ROR_op),
        .ROL_op(ROL_op), .IncPC_op(IncPC), .Z_next(Znext)
    );
    register #(.size(64)) Z (Zout_data, Znext, clr, clk, Zin);

    // --- Main Bus ---
    bus main_bus (
        .BusMuxOut(BusMuxOut), 
        .sel(BusMuxSel),
        .R0in(R0out), .R1in(R1out), .R2in(R2out), .R3in(R3out), .R4in(R4out),
        .R5in(R5out), .R6in(R6out), .R7in(R7out), .R8in(R8out), .R9in(R9out),
        .R10in(R10out), .R11in(R11out), .R12in(R12out), .R13in(R13out), 
        .R14in(R14out), .R15in(R15out), 
        .HIin(HIout_data), .LOin(LOout_data), .Zhighin(Zhighout_data), .Zlowin(Zlowout_data),
        .PCin(PCout_data), .MDRin(MDRout_data), .InPort(InPort_data), .C_sign_extin(C_sign_ext)
    );

endmodule