`timescale 1ns/10ps

module DataPath (
    input clk, clr,
    
    // Phase 1 Control Signals
    input PCout, Zhighout, Zlowout, MDRout, MARin, Zin, PCin, MDRin, IRin, Yin, IncPC, Read, Write,
    
    // Phase 2 Encode & Branch Signals
    input Gra, Grb, Grc, Rin, Rout, BAout, Cout, CONin,
    output CON,
    
    // HI/LO and I/O Signals
    input HIin, LOin, HIout, LOout, InPortout, OutPortin,
    input [31:0] InPort_data_in,
    output [31:0] OutPort_data_out,
    
    // ALU Control Signals
    input AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op
);

    // --------------------------------------------------------
    // INTERNAL WIRES
    // --------------------------------------------------------
    
    wire [31:0] BusMuxOut;
    wire [63:0] Z_data_in;
    wire [4:0]  bus_sel;
    wire [31:0] Mdatain;     // Data coming from RAM to MDR
    
    // Phase 2 Select & Encode Wires (Fixes Error 3: Out-of-bounds indexing)
    wire [15:0] R_in;
    wire [15:0] R_out;
    wire [31:0] C_sign_ext;
    
    // Component to Bus Wires
    wire [31:0] busMuxIn_R0, busMuxIn_R1, busMuxIn_R2, busMuxIn_R3, 
                busMuxIn_R4, busMuxIn_R5, busMuxIn_R6, busMuxIn_R7, 
                busMuxIn_R8, busMuxIn_R9, busMuxIn_R10, busMuxIn_R11, 
                busMuxIn_R12, busMuxIn_R13, busMuxIn_R14, busMuxIn_R15;
                
    wire [31:0] busMuxIn_HI, busMuxIn_LO, busMuxIn_Zhigh, busMuxIn_Zlow;
    wire [31:0] busMuxIn_PC, busMuxIn_MDR, busMuxIn_InPort;
    wire [31:0] busMuxIn_Y, busMuxIn_IR, busMuxIn_MAR;

    // --------------------------------------------------------
    // CONTROL LOGIC INSTANTIATIONS
    // --------------------------------------------------------

    // Select and Encode Logic
    select_encode_logic encode_logic_inst (
        .IR(busMuxIn_IR),
        .Gra(Gra), .Grb(Grb), .Grc(Grc), 
        .Rin(Rin), .Rout(Rout), .BAout(BAout), 
        .R_in(R_in),
        .R_out(R_out),
        .C_sign_ext(C_sign_ext)
    );

    // Condition Flip-Flop Logic (For Branching)
    con_ff_logic con_ff_inst (
        .clk(clk),
        .CONin(CONin),
        .IR_C2(busMuxIn_IR[20:19]), 
        .BusMuxOut(BusMuxOut),      
        .CON(CON)                   
    );

    // --------------------------------------------------------
    // GENERAL PURPOSE REGISTERS (0 to 15)
    // --------------------------------------------------------

    // Special Phase 2 Register 0
    register_r0 R0 (
        .busMuxIn(busMuxIn_R0), 
        .busMuxOut(BusMuxOut), 
        .clr(clr), 
        .clock(clk), 
        .Rin(R_in[ 0 ]),     // <--- Now correctly slicing bit 0
        .BAout(BAout)
    );

    // Standard Registers
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
    // DEDICATED REGISTERS & DATAPATH COMPONENTS
    // --------------------------------------------------------

    register PC_reg  (.busMuxIn(busMuxIn_PC),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(PCin));
    register Y_reg   (.busMuxIn(busMuxIn_Y),   .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(Yin));
    register IR_reg  (.busMuxIn(busMuxIn_IR),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(IRin));
    register MAR_reg (.busMuxIn(busMuxIn_MAR), .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(MARin));
    
    register HI_reg  (.busMuxIn(busMuxIn_HI),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(HIin));
    register LO_reg  (.busMuxIn(busMuxIn_LO),  .busMuxOut(BusMuxOut), .clr(clr), .clock(clk), .Rin(LOin));
    
    // Z Register Split (64-bits split into 2 32-bit segments)
    register Zhigh_reg (.busMuxIn(busMuxIn_Zhigh), .busMuxOut(Z_data_in[63:32]), .clr(clr), .clock(clk), .Rin(Zin));
    register Zlow_reg  (.busMuxIn(busMuxIn_Zlow),  .busMuxOut(Z_data_in[31:0]),  .clr(clr), .clock(clk), .Rin(Zin));

    // Input/Output Ports
    register InPort_reg  (.busMuxIn(busMuxIn_InPort), .busMuxOut(InPort_data_in), .clr(clr), .clock(clk), .Rin(1'b1));
    register OutPort_reg (.busMuxIn(OutPort_data_out),.busMuxOut(BusMuxOut),      .clr(clr), .clock(clk), .Rin(OutPortin));

    // --------------------------------------------------------
    // MEMORY SUBSYSTEM
    // --------------------------------------------------------
    
    MDR MDR_reg (
        .MDRout(busMuxIn_MDR), 
        .Mdatain(Mdatain), 
        .busMuxOut(BusMuxOut), 
        .Read(Read), 
        .clr(clr), 
        .clock(clk), 
        .MDRin(MDRin)
    );

    ram_512x32 ram_inst (
        .clk(clk),
        .Read(Read),
        .Write(Write),
        .Address(busMuxIn_MAR[8:0]),
        .DataIn(busMuxIn_MDR),    // Writes MDR value into RAM
        .DataOut(Mdatain)         // RAM outputs to Mdatain wire
    );

    // --------------------------------------------------------
    // ALU & BUS INSTANTIATIONS
    // --------------------------------------------------------

    alu alu_inst (
        .Y(busMuxIn_Y),         
        .Bus(BusMuxOut),        
        .PC(busMuxIn_PC),       
        
        .AND_op(AND_op), .OR_op(OR_op), .NOT_op(NOT_op), .NEG_op(NEG_op),
        .ADD_op(ADD_op), .SUB_op(SUB_op), .MUL_op(MUL_op), .DIV_op(DIV_op),
        .SHR_op(SHR_op), .SHRA_op(SHRA_op), .SHL_op(SHL_op),
        .ROR_op(ROR_op), .ROL_op(ROL_op),
        
        .IncPC_op(IncPC),
        .Z_next(Z_data_in)      // 64-bit result feeds back to Zhigh and Zlow registers
    );

    encoder_32to5 bus_encoder (
        .R_out(R_out),
        .HIout(HIout), .LOout(LOout), .Zhighout(Zhighout), .Zlowout(Zlowout),
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        .sel(bus_sel)
    );

    bus bus_inst (
        .BusMuxOut(BusMuxOut),
        .sel(bus_sel),
        
        .R0in(busMuxIn_R0), .R1in(busMuxIn_R1), .R2in(busMuxIn_R2), .R3in(busMuxIn_R3), 
        .R4in(busMuxIn_R4), .R5in(busMuxIn_R5), .R6in(busMuxIn_R6), .R7in(busMuxIn_R7), 
        .R8in(busMuxIn_R8), .R9in(busMuxIn_R9), .R10in(busMuxIn_R10), .R11in(busMuxIn_R11), 
        .R12in(busMuxIn_R12), .R13in(busMuxIn_R13), .R14in(busMuxIn_R14), .R15in(busMuxIn_R15), 
        
        .HIin(busMuxIn_HI), .LOin(busMuxIn_LO), 
        .Zhighin(busMuxIn_Zhigh), .Zlowin(busMuxIn_Zlow), 
        .PCin(busMuxIn_PC), .MDRin(busMuxIn_MDR), 
        .InPort(busMuxIn_InPort), .C_sign_extin(C_sign_ext)
    );

endmodule