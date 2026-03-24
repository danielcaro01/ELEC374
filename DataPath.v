`timescale 1ns/10ps
module DataPath ( 
    input clk, clr, 
    
    // Phase 1 Control Signals
    input PCout, Zhighout, Zlowout, MDRout, MARin, Zin, PCin, MDRin, IRin, Yin, IncPC, Read, Write, 
    
    // Phase 2 Control Signals
    input Gra, Grb, Grc, Rin, Rout, BAout, Cout, CONin, 
    output CON, 
    
    // Branch, HI/LO, and I/O Signals
    input HIin, LOin, HIout, LOout, InPortout, OutPortin, 
    input [ 31:0 ] InPort_data_in, 
    output [ 31:0 ] OutPort_data_out, 
    
    // ALU Operation Signals
    input AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op 
);

    // --------------------------------------------------------
    // INTERNAL WIRES & BUS CONNECTIONS
    // --------------------------------------------------------
    wire [ 31:0 ] BusMuxOut;
    
    // Wires from registers to the Bus Multiplexer
    wire [ 31:0 ] busMuxIn_R0, busMuxIn_R1, busMuxIn_R2, busMuxIn_R3, busMuxIn_R4, busMuxIn_R5, busMuxIn_R6, busMuxIn_R7;
    wire [ 31:0 ] busMuxIn_R8, busMuxIn_R9, busMuxIn_R10, busMuxIn_R11, busMuxIn_R12, busMuxIn_R13, busMuxIn_R14, busMuxIn_R15;
    wire [ 31:0 ] busMuxIn_HI, busMuxIn_LO, busMuxIn_Zhigh, busMuxIn_Zlow, busMuxIn_PC, busMuxIn_MDR, busMuxIn_InPort;
    
    // Other critical internal pathways
    wire [ 31:0 ] IR_out, Y_out, MAR_out, RAM_data_out, C_sign_ext;
    wire [ 63:0 ] Z_next;
    
    // Select and Encode Wires (The FIX for your empty Y_reg waveform!)
    wire [ 15:0 ] R_in, R_out;
    wire [ 4:0 ] BusMuxSel;

    // --------------------------------------------------------
    // PHASE 2: SELECT & ENCODE LOGIC
    // --------------------------------------------------------
    // Extracts Ra, Rb, Rc from the IR and decodes which register should read/write
    select_encode_logic select_encode_inst (
        .IR(IR_out), 
        .Gra(Gra), .Grb(Grb), .Grc(Grc), 
        .Rin(Rin), .Rout(Rout), .BAout(BAout), 
        .R_in(R_in), 
        .R_out(R_out), 
        .C_sign_ext(C_sign_ext)
    );

    // Converts the decoded R_out signals into a 5-bit select signal for the Bus
    encoder_32to5 encoder_inst (
        .R_out(R_out), 
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout), 
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout), 
        .sel(BusMuxSel)
    );

    // --------------------------------------------------------
    // MAIN SYSTEM BUS (32:1 Multiplexer)
    // --------------------------------------------------------
    bus bus_inst (
        .BusMuxOut(BusMuxOut), 
        .sel(BusMuxSel), 
        .R0in(busMuxIn_R0), .R1in(busMuxIn_R1), .R2in(busMuxIn_R2), .R3in(busMuxIn_R3), 
        .R4in(busMuxIn_R4), .R5in(busMuxIn_R5), .R6in(busMuxIn_R6), .R7in(busMuxIn_R7), 
        .R8in(busMuxIn_R8), .R9in(busMuxIn_R9), .R10in(busMuxIn_R10), .R11in(busMuxIn_R11), 
        .R12in(busMuxIn_R12), .R13in(busMuxIn_R13), .R14in(busMuxIn_R14), .R15in(busMuxIn_R15), 
        .HIin(busMuxIn_HI), .LOin(busMuxIn_LO), .Zhighin(busMuxIn_Zhigh), .Zlowin(busMuxIn_Zlow), 
        .PCin(busMuxIn_PC), .MDRin(busMuxIn_MDR), .InPort(busMuxIn_InPort), .C_sign_extin(C_sign_ext)
    );

    // --------------------------------------------------------
    // GENERAL PURPOSE REGISTERS (R0 - R15)
    // --------------------------------------------------------
    // Register 0 uses the special register_r0 module to support BAout gating [3]
    register_r0 R0 (.busMuxIn(busMuxIn_R0), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 0 ]), .BAout(BAout));
    
    // Explicitly sliced arrays guarantee no "Port Size Mismatch" warnings
    register R1  (.busMuxIn(busMuxIn_R1),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 1 ]));
    register R2  (.busMuxIn(busMuxIn_R2),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 2 ]));
    register R3  (.busMuxIn(busMuxIn_R3),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 3 ]));
    register R4  (.busMuxIn(busMuxIn_R4),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 4 ]));
    register R5  (.busMuxIn(busMuxIn_R5),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 5 ]));
    register R6  (.busMuxIn(busMuxIn_R6),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 6 ]));
    register R7  (.busMuxIn(busMuxIn_R7),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 7 ]));
    register R8  (.busMuxIn(busMuxIn_R8),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 8 ]));
    register R9  (.busMuxIn(busMuxIn_R9),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 9 ]));
    register R10 (.busMuxIn(busMuxIn_R10), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 10 ]));
    register R11 (.busMuxIn(busMuxIn_R11), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 11 ]));
    register R12 (.busMuxIn(busMuxIn_R12), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 12 ]));
    register R13 (.busMuxIn(busMuxIn_R13), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 13 ]));
    register R14 (.busMuxIn(busMuxIn_R14), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 14 ]));
    register R15 (.busMuxIn(busMuxIn_R15), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(R_in[ 15 ]));

    // --------------------------------------------------------
    // SYSTEM REGISTERS
    // --------------------------------------------------------
    register PC  (.busMuxIn(busMuxIn_PC), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(PCin));
    register IR  (.busMuxIn(IR_out),      .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(IRin));
    register Y   (.busMuxIn(Y_out),       .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(Yin));
    register MAR (.busMuxIn(MAR_out),     .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(MARin));
    register HI  (.busMuxIn(busMuxIn_HI), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(HIin));
    register LO  (.busMuxIn(busMuxIn_LO), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(LOin));
    
    // Z Register split into high and low components to accept the 64-bit ALU output [4]
    register Z_high (.busMuxIn(busMuxIn_Zhigh), .busMuxOut(Z_next[ 63:32 ]), .clr(clr), .clock(clk), .Rin(Zin));
    register Z_low  (.busMuxIn(busMuxIn_Zlow),  .busMuxOut(Z_next[ 31:0 ]),  .clr(clr), .clock(clk), .Rin(Zin));

    // --------------------------------------------------------
    // PHASE 2: MEMORY SUBSYSTEM
    // --------------------------------------------------------
    // The MDR contains a multiplexer to choose between Bus Data or RAM Data [5, 6]
    MDR mdr_inst (
        .MDRout(busMuxIn_MDR), 
        .Mdatain(RAM_data_out), 
        .busMuxOut(BusMuxOut), 
        .Read(Read), 
        .clr(clr), 
        .clock(clk), 
        .MDRin(MDRin)
    );

    // Main 512x32 Random Access Memory unit
    ram_512x32 ram_inst (
        .clk(clk), 
        .Read(Read), 
        .Write(Write), 
        .Address(MAR_out[ 8:0 ]), 
        .DataIn(busMuxIn_MDR), 
        .DataOut(RAM_data_out)
    );

    // --------------------------------------------------------
    // PHASE 2: I/O PORTS & CON FF
    // --------------------------------------------------------
    register InPort  (.busMuxIn(busMuxIn_InPort),  .busMuxOut(InPort_data_in), .clr(clr), .clock(clk), .Rin(1'b1)); 
    register OutPort (.busMuxIn(OutPort_data_out), .busMuxOut(BusMuxOut),      .clr(clr), .clock(clk), .Rin(OutPortin));

    con_ff_logic con_ff_inst (
        .clk(clk), 
        .CONin(CONin), 
        .IR_C2(IR_out[ 20:19 ]),  // Checks IR bits 20 and 19 for branch conditions [7]
        .BusMuxOut(BusMuxOut), 
        .CON(CON)
    );

    // --------------------------------------------------------
    // ARITHMETIC LOGIC UNIT
    // --------------------------------------------------------
    alu alu_inst (
        .Y(Y_out), 
        .Bus(BusMuxOut), 
        .PC(busMuxIn_PC), 
        .AND_op(AND_op), .OR_op(OR_op), .NOT_op(NOT_op), .NEG_op(NEG_op), 
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op), 
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op), 
        .ROR_op(ROR_op), .ROL_op(ROL_op), .IncPC_op(IncPC), 
        .Z_next(Z_next)
    );

endmodule