`timescale 1ns/10ps
module DataPath (
    input clk,
    input reset,
    input stop,
    input [31:0] InPort_data_in,
    output [31:0] OutPort_data_out,

    output [31:0] PC_out, IR_out, MAR_out, MDR_out, HI_out, LO_out, Zhigh_out, Zlow_out,
    output [31:0] R0_out, R1_out, R2_out, R3_out, R4_out, R5_out, R6_out, R7_out,
    output [31:0] R8_out, R9_out, R10_out, R11_out, R12_out, R13_out, R14_out, R15_out
);

    wire PCout, Zhighout, Zlowout, MDRout, MARin, Zin, PCin, MDRin, IRin, Yin, IncPC, Read, Write;
    wire AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op;
    wire Gra, Grb, Grc, Rin, Rout, BAout, Cout, CONin, CON;
    wire HIin, LOin, HIout, LOout, InPortout, OutPortin;
    wire Clear, Run;

    wire [31:0] BusMuxOut;
    wire [31:0] C_sign_ext;
    wire [31:0] RAM_data_out;
    wire [15:0] R_in_ctrl;
    wire [15:0] R_out_ctrl;
    wire [4:0] BusSel;

    wire [31:0] Y_out;
    wire [63:0] Z_out_full;
    wire [63:0] Z_next;

    assign Zhigh_out = Z_out_full[63:32];
    assign Zlow_out  = Z_out_full[31:0];

    control_unit CU (
        .Clock(clk), .Reset(reset), .Stop(stop), .CON_FF(CON),
        .IR(IR_out),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout), .Cout(Cout),
        .Yin(Yin), .Zin(Zin), .PCout(PCout), .IncPC(IncPC),
        .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout),
        .Zhighout(Zhighout), .Zlowout(Zlowout), .HIout(HIout), .LOout(LOout),
        .HIin(HIin), .LOin(LOin), .CONin(CONin), .PCin(PCin), .IRin(IRin),
        .InPortout(InPortout), .OutPortin(OutPortin),
        .Read(Read), .Write(Write), .Clear(Clear), .Run(Run),
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op),
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op), .ROR_op(ROR_op), .ROL_op(ROL_op),
        .AND_op(AND_op), .OR_op(OR_op), .NEG_op(NEG_op), .NOT_op(NOT_op)
    );

    select_encode_logic SEL (
        .IR(IR_out),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .R_in(R_in_ctrl), .R_out(R_out_ctrl),
        .C_sign_ext(C_sign_ext)
    );

    con_ff_logic CON_FF_inst (
        .clk(clk),
        .CONin(CONin),
        .IR_C2(IR_out[20:19]),
        .BusMuxOut(BusMuxOut),
        .CON(CON)
    );

    register_r0 R0_reg(.busMuxIn(R0_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl), .BAout(BAout));
    register R1_reg(.busMuxIn(R1_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[1]));
    register R2_reg(.busMuxIn(R2_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[2]));
    register R3_reg(.busMuxIn(R3_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[3]));
    register R4_reg(.busMuxIn(R4_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[4]));
    register R5_reg(.busMuxIn(R5_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[5]));
    register R6_reg(.busMuxIn(R6_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[6]));
    register R7_reg(.busMuxIn(R7_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[7]));
    register R8_reg(.busMuxIn(R8_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[8]));
    register R9_reg(.busMuxIn(R9_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[9]));
    register R10_reg(.busMuxIn(R10_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[10]));
    register R11_reg(.busMuxIn(R11_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[11]));
    register R12_reg(.busMuxIn(R12_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[12]));
    register R13_reg(.busMuxIn(R13_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[13]));
    register R14_reg(.busMuxIn(R14_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[14]));
    register R15_reg(.busMuxIn(R15_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[15]));

    register PC_reg(.busMuxIn(PC_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(PCin));
    register IR_reg(.busMuxIn(IR_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(IRin));
    register Y_reg(.busMuxIn(Y_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(Yin));
    register HI_reg(.busMuxIn(HI_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(HIin));
    register LO_reg(.busMuxIn(LO_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(LOin));
    register MAR_reg(.busMuxIn(MAR_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(MARin));
    register OutPort_reg(.busMuxIn(OutPort_data_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(OutPortin));

    register #(64) Z_reg(.busMuxIn(Z_out_full), .busMuxOut(Z_next), .clr(Clear), .clock(clk), .Rin(Zin));

    ram_512x32 RAM (
        .clk(clk),
        .Read(Read),
        .Write(Write),
        .Address(MAR_out[8:0]),
        .DataIn(MDR_out),
        .DataOut(RAM_data_out)
    );

    MDR MDR_inst (
        .MDRout(MDR_out),
        .Mdatain(RAM_data_out),
        .busMuxOut(BusMuxOut),
        .Read(Read),
        .clr(Clear),
        .clock(clk),
        .MDRin(MDRin)
    );

    alu ALU_inst (
        .Y(Y_out),
        .Bus(BusMuxOut),
        .PC(PC_out),
        .AND_op(AND_op), .OR_op(OR_op), .NOT_op(NOT_op), .NEG_op(NEG_op),
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op),
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op), .ROR_op(ROR_op), .ROL_op(ROL_op),
        .IncPC_op(IncPC),
        .Z_next(Z_next)
    );

    encoder_32to5 Encoder (
        .R_out(R_out_ctrl),
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout),
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        .sel(BusSel)
    );

    bus BUS_inst (
        .BusMuxOut(BusMuxOut),
        .sel(BusSel),
        .R0in(R0_out), .R1in(R1_out), .R2in(R2_out), .R3in(R3_out),
        .R4in(R4_out), .R5in(R5_out), .R6in(R6_out), .R7in(R7_out),
        .R8in(R8_out), .R9in(R9_out), .R10in(R10_out), .R11in(R11_out),
        .R12in(R12_out), .R13in(R13_out), .R14in(R14_out), .R15in(R15_out),
        .HIin(HI_out), .LOin(LO_out), .Zhighin(Zhigh_out), .Zlowin(Zlow_out),
        .PCin(PC_out), .MDRin(MDR_out), .InPort(InPort_data_in), .C_sign_extin(C_sign_ext)
    );

endmodule