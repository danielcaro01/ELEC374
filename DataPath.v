`timescale 1ns/10ps

// Top-level Datapath module routing the entire CPU architecture.
module DataPath (
    // System execution and clocking ports
    input clk,
    input reset,
    input stop,
    
    // I/O peripheral data buses
    input [31:0] InPort_data_in,
    output [31:0] OutPort_data_out,
    
    // Top-level execution state indicator
    output Run_out,
    
    // Debugging probes for simulator waveform visibility
    output [31:0] PC_out, IR_out, MAR_out, MDR_out, HI_out, LO_out, Zhigh_out, Zlow_out,
    output [31:0] R0_out, R1_out, R2_out, R3_out, R4_out, R5_out, R6_out, R7_out,
    output [31:0] R8_out, R9_out, R10_out, R11_out, R12_out, R13_out, R14_out, R15_out
);

    // --------------------------------------------------------------------
    // Control Signals & Internal Buses
    // --------------------------------------------------------------------
    wire [31:0] BusMuxOut, Mdatain, C_sign_extended;
    wire [15:0] R_in_ctrl, R_out_ctrl;
    wire [31:0] Y_val;
    wire [63:0] Z_alu_out;
    wire CON_FF;
    
    // FSM outputs routing to datapath components
    wire Gra, Grb, Grc, Rin, Rout, BAout;
    wire Yin, Zin, PCout, IncPC, MARin, MDRin, MDRout;
    wire Read, Write, Clear;
    wire ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op;
    wire ROR_op, ROL_op, AND_op, OR_op, NEG_op, NOT_op;
    wire HIin, LOin, CONin, PCin, IRin, OutPortin, Cout;
    wire Zlowout, Zhighout, HIout, LOout, InPortout;

    // --------------------------------------------------------------------
    // Control Unit FSM
    // --------------------------------------------------------------------
    // Drives all operational states, ALU commands, and register enables
    control_unit CU (
        .Clock(clk), .Reset(reset), .Stop(stop), .CON_FF(CON_FF), 
        .IR(IR_out), 
        .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .Yin(Yin), .Zin(Zin), .PCout(PCout), .IncPC(IncPC), .MARin(MARin), .MDRin(MDRin), .MDRout(MDRout),
        .Read(Read), .Write(Write), .Clear(Clear),
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op), 
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op), .ROR_op(ROR_op), 
        .ROL_op(ROL_op), .AND_op(AND_op), .OR_op(OR_op), .NEG_op(NEG_op), .NOT_op(NOT_op),
        .HIin(HIin), .LOin(LOin), .CONin(CONin), .PCin(PCin), .IRin(IRin), .OutPortin(OutPortin), .Cout(Cout),
        .Zlowout(Zlowout), .Zhighout(Zhighout), .HIout(HIout), .LOout(LOout), .InPortout(InPortout),
        .Run(Run_out)
    );

    // --------------------------------------------------------------------
    // Instruction Decoding & Condition Logic
    // --------------------------------------------------------------------
    // Decodes Gra, Grb, Grc to assert specific general-purpose register enables
    select_encode_logic SEL (
        .IR(IR_out), .Gra(Gra), .Grb(Grb), .Grc(Grc), 
        .Rin(Rin), .Rout(Rout), .BAout(BAout),
        .R_in(R_in_ctrl), .R_out(R_out_ctrl), .C_sign_ext(C_sign_extended)
    );

    // Evaluates branch conditions against the current bus value
    con_ff_logic CON_LOGIC (
        .clk(clk), .CONin(CONin), .IR_C2(IR_out[20:19]), .BusMuxOut(BusMuxOut), .CON(CON_FF)
    );

    // --------------------------------------------------------------------
    // Memory Subsystem
    // --------------------------------------------------------------------
    // Synchronous block RAM storing machine code and program data
    ram_512x32 RAM (
        .clk(clk), .Read(Read), .Write(Write), .Address(MAR_out[8:0]), .DataIn(MDR_out), .DataOut(Mdatain)
    );

    // Memory Address Register
    register MAR (.busMuxIn(MAR_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(MARin));
    
    // Memory Data Register (handles selection between memory reads and bus transfers)
    MDR MDR_reg (
        .MDRout(MDR_out), .Mdatain(Mdatain), .busMuxOut(BusMuxOut), 
        .Read(Read), .clr(Clear), .clock(clk), .MDRin(MDRin)
    );

    // --------------------------------------------------------------------
    // General Purpose Register File (R0-R15)
    // --------------------------------------------------------------------
    // R0 implements special logic to output 0x0 during base-addressing operations
    register_r0 R0 (.busMuxIn(R0_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl), .BAout(BAout));
    register R1 (.busMuxIn(R1_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[1]));
    register R2 (.busMuxIn(R2_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[2]));
    register R3 (.busMuxIn(R3_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[3]));
    register R4 (.busMuxIn(R4_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[4]));
    register R5 (.busMuxIn(R5_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[5]));
    register R6 (.busMuxIn(R6_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[6]));
    register R7 (.busMuxIn(R7_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[7]));
    register R8 (.busMuxIn(R8_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[8]));
    register R9 (.busMuxIn(R9_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[9]));
    register R10 (.busMuxIn(R10_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[10]));
    register R11 (.busMuxIn(R11_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[11]));
    register R12 (.busMuxIn(R12_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[12]));
    register R13 (.busMuxIn(R13_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[13]));
    register R14 (.busMuxIn(R14_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[14]));
    register R15 (.busMuxIn(R15_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(R_in_ctrl[15]));

    // --------------------------------------------------------------------
    // Special Purpose Registers
    // --------------------------------------------------------------------
    register PC (.busMuxIn(PC_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(PCin));
    register IR (.busMuxIn(IR_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(IRin));
    register Y_reg (.busMuxIn(Y_val), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(Yin));
    register Z_high (.busMuxIn(Zhigh_out), .busMuxOut(Z_alu_out[63:32]), .clr(Clear), .clock(clk), .Rin(Zin));
    register Z_low (.busMuxIn(Zlow_out), .busMuxOut(Z_alu_out[31:0]), .clr(Clear), .clock(clk), .Rin(Zin));
    register HI_reg (.busMuxIn(HI_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(HIin));
    register LO_reg (.busMuxIn(LO_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(LOin));
    
    // --------------------------------------------------------------------
    // I/O Interface
    // --------------------------------------------------------------------
    // InPort reads system hardware slides/buttons; OutPort drives Hex displays
    register InPort (.busMuxIn(), .busMuxOut(InPort_data_in), .clr(Clear), .clock(clk), .Rin(1'b0)); 
    register OutPort (.busMuxIn(OutPort_data_out), .busMuxOut(BusMuxOut), .clr(Clear), .clock(clk), .Rin(OutPortin));

    // --------------------------------------------------------------------
    // Arithmetic Logic Unit (ALU)
    // --------------------------------------------------------------------
    // Computes arithmetic and logic operations between Y and the Bus, storing to Z
    alu Main_ALU (
        .Y(Y_val), .Bus(BusMuxOut), .PC(PC_out), 
        .AND_op(AND_op), .OR_op(OR_op), .NOT_op(NOT_op), .NEG_op(NEG_op), 
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op), 
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op), .ROR_op(ROR_op), 
        .ROL_op(ROL_op), .IncPC_op(IncPC), 
        .Z_next(Z_alu_out)
    );

    // --------------------------------------------------------------------
    // 32-to-5 Encoder and Bi-directional Bus Multiplexer
    // --------------------------------------------------------------------
    wire [4:0] mux_sel;
    
    // Generates the selection signal for the bus multiplexer based on output enables
    encoder_32to5 Encoder (
        .R_out(R_out_ctrl), .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout), 
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout), 
        .sel(mux_sel)
    );
    
    // Routes the selected register's value onto the main 32-bit bus
    bus Main_Bus (
        .BusMuxOut(BusMuxOut), .sel(mux_sel), 
        .R0in(R0_out), .R1in(R1_out), .R2in(R2_out), .R3in(R3_out), 
        .R4in(R4_out), .R5in(R5_out), .R6in(R6_out), .R7in(R7_out), 
        .R8in(R8_out), .R9in(R9_out), .R10in(R10_out), .R11in(R11_out), 
        .R12in(R12_out), .R13in(R13_out), .R14in(R14_out), .R15in(R15_out), 
        .HIin(HI_out), .LOin(LO_out), .Zhighin(Zhigh_out), .Zlowin(Zlow_out), 
        .PCin(PC_out), .MDRin(MDR_out), .InPort(InPort_data_in), .C_sign_extin(C_sign_extended)
    );

endmodule