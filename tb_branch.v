`timescale 1ns/10ps
module tb_branch;

    reg clk, clr;
    
    // Phase 1 Control Signals
    reg PCout, Zhighout, Zlowout, MDRout, MARin, Zin, PCin, MDRin, IRin, Yin, IncPC, Read, Write;
    reg AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op;
    
    // Phase 2 Control Signals
    reg Gra, Grb, Grc, Rin, Rout, BAout, Cout, CONin;
    wire CON; 
    reg HIin, LOin, HIout, LOout, InPortout, OutPortin;
    reg [ 31:0 ] InPort_data_in;
    wire [ 31:0 ] OutPort_data_out;

    // Instantiate your 45-Port DataPath
    DataPath DUT (
        .clk(clk), .clr(clr), 
        .PCout(PCout), .Zhighout(Zhighout), .Zlowout(Zlowout), .MDRout(MDRout), 
        .MARin(MARin), .Zin(Zin), .PCin(PCin), .MDRin(MDRin), .IRin(IRin), .Yin(Yin), 
        .IncPC(IncPC), .Read(Read), .Write(Write), 
        
        .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout), .Cout(Cout),
        .CONin(CONin), .CON(CON),
        
        .HIin(HIin), .LOin(LOin), .HIout(HIout), .LOout(LOout),
        .InPortout(InPortout), .OutPortin(OutPortin),
        .InPort_data_in(InPort_data_in), .OutPort_data_out(OutPort_data_out),
        
        .AND_op(AND_op), .OR_op(OR_op), .ADD_op(ADD_op), .SUB_op(SUB_op), 
        .MUL_op(MUL_op), .DIV_op(DIV_op), .SHR_op(SHR_op), .SHRA_op(SHRA_op), 
        .SHL_op(SHL_op), .ROR_op(ROR_op), .ROL_op(ROL_op), .NEG_op(NEG_op), .NOT_op(NOT_op)
    );

    // --------------------------------------------------------
    // MEMORY INITIALIZATION (Natural Branch Flow)
    // --------------------------------------------------------
    initial begin
        // Case 1: brzr R3, 48 (Branch Taken)
        // Starts at PC = 0. Jumps to 0 + 1 + 48 = 49 (0x031).
        DUT.ram_inst.memory[ 9'h000 ] = 32'h01800030; 

        // Case 2: brnz R3, 48 (Branch Fails)
        // Placed at the jump target of Case 1 (0x031). Increments to 0x032.
        DUT.ram_inst.memory[ 9'h031 ] = 32'h01880030; 

        // Case 3: brpl R3, 48 (Branch Taken)
        // Placed at the incremented target of Case 2 (0x032). Jumps to 50 + 1 + 48 = 99 (0x063).
        DUT.ram_inst.memory[ 9'h032 ] = 32'h01900030; 

        // Case 4: brmi R3, 48 (Branch Fails)
        // Placed at the jump target of Case 3 (0x063). Increments to 0x064.
        DUT.ram_inst.memory[ 9'h063 ] = 32'h01980030; 
    end

    // --------------------------------------------------------
    // DELAYED REGISTER PRELOAD
    // --------------------------------------------------------
    initial begin
        #35; 
        // Preload R3 with 0 to set the condition baseline for all tests.
        force DUT.R3.Q = 32'h0000_0000; 
        #10; 
        release DUT.R3.Q;
    end

    // --------------------------------------------------------
    // CLOCK & RESET GENERATION
    // --------------------------------------------------------
    initial begin clk = 0; forever #10 clk = ~clk; end
    initial begin clr = 1; #25 clr = 0; end

    // --------------------------------------------------------
    // SIMULATION DUMP & TIMEOUT
    // --------------------------------------------------------
    initial begin $dumpfile("tb_branch.vcd"); $dumpvars; end
    initial begin #127500; $display("Simulation complete."); $finish; end

    // --------------------------------------------------------
    // FSM STATES
    // --------------------------------------------------------
    parameter Default = 5'd0, 
              T0_1=5'd1, T1_1=5'd2, T2_1=5'd3, T3_1=5'd4, T4_1=5'd5, T5_1=5'd6, T6_1=5'd7,
              T0_2=5'd8, T1_2=5'd9, T2_2=5'd10, T3_2=5'd11, T4_2=5'd12, T5_2=5'd13, T6_2=5'd14,
              T0_3=5'd15, T1_3=5'd16, T2_3=5'd17, T3_3=5'd18, T4_3=5'd19, T5_3=5'd20, T6_3=5'd21,
              T0_4=5'd22, T1_4=5'd23, T2_4=5'd24, T3_4=5'd25, T4_4=5'd26, T5_4=5'd27, T6_4=5'd28;
    reg [ 4:0 ] Present_state = Default;

    always @(posedge clk) begin
        if (clr) Present_state <= Default;
        else case (Present_state)
            Default: Present_state <= T0_1;
            
            T0_1: Present_state <= T1_1; T1_1: Present_state <= T2_1; T2_1: Present_state <= T3_1;
            T3_1: Present_state <= T4_1; T4_1: Present_state <= T5_1; T5_1: Present_state <= T6_1;
            T6_1: Present_state <= T0_2; 
            
            T0_2: Present_state <= T1_2; T1_2: Present_state <= T2_2; T2_2: Present_state <= T3_2;
            T3_2: Present_state <= T4_2; T4_2: Present_state <= T5_2; T5_2: Present_state <= T6_2;
            T6_2: Present_state <= T0_3; 
            
            T0_3: Present_state <= T1_3; T1_3: Present_state <= T2_3; T2_3: Present_state <= T3_3;
            T3_3: Present_state <= T4_3; T4_3: Present_state <= T5_3; T5_3: Present_state <= T6_3;
            T6_3: Present_state <= T0_4; 
            
            T0_4: Present_state <= T1_4; T1_4: Present_state <= T2_4; T2_4: Present_state <= T3_4;
            T3_4: Present_state <= T4_4; T4_4: Present_state <= T5_4; T5_4: Present_state <= T6_4;
            T6_4: Present_state <= T6_4; 
        endcase
    end

    // --------------------------------------------------------
    // FSM OUTPUTS
    // --------------------------------------------------------
    always @(Present_state) begin
        // Reset all signals to 0 to prevent inferred latches
        PCout=0; Zhighout=0; Zlowout=0; MDRout=0; MARin=0; Zin=0; PCin=0; MDRin=0; IRin=0; Yin=0; IncPC=0; Read=0; Write=0;
        Gra=0; Grb=0; Grc=0; Rin=0; Rout=0; BAout=0; Cout=0; CONin=0; HIin=0; LOin=0; HIout=0; LOout=0; InPortout=0; OutPortin=0;
        AND_op=0; OR_op=0; ADD_op=0; SUB_op=0; MUL_op=0; DIV_op=0; SHR_op=0; SHRA_op=0; SHL_op=0; ROR_op=0; ROL_op=0; NEG_op=0; NOT_op=0;

        case (Present_state)
            // ------------- CASE 1: brzr R3, 48 ------------- //
            T0_1: begin PCout = 1; MARin = 1; IncPC = 1; Zin = 1; end
            T1_1: begin Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; end
            T2_1: begin MDRout = 1; IRin = 1; end
            
            T3_1: begin Gra = 1; Rout = 1; CONin = 1; end
            T4_1: begin PCout = 1; Yin = 1; end
            T5_1: begin Cout = 1; ADD_op = 1; Zin = 1; end
            T6_1: begin Zlowout = 1; PCin = CON; end

            // ------------- CASE 2: brnz R3, 48 ------------- //
            T0_2: begin PCout = 1; MARin = 1; IncPC = 1; Zin = 1; end
            T1_2: begin Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; end
            T2_2: begin MDRout = 1; IRin = 1; end
            
            T3_2: begin Gra = 1; Rout = 1; CONin = 1; end
            T4_2: begin PCout = 1; Yin = 1; end
            T5_2: begin Cout = 1; ADD_op = 1; Zin = 1; end
            T6_2: begin Zlowout = 1; PCin = CON; end

            // ------------- CASE 3: brpl R3, 48 ------------- //
            T0_3: begin PCout = 1; MARin = 1; IncPC = 1; Zin = 1; end
            T1_3: begin Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; end
            T2_3: begin MDRout = 1; IRin = 1; end
            
            T3_3: begin Gra = 1; Rout = 1; CONin = 1; end
            T4_3: begin PCout = 1; Yin = 1; end
            T5_3: begin Cout = 1; ADD_op = 1; Zin = 1; end
            T6_3: begin Zlowout = 1; PCin = CON; end

            // ------------- CASE 4: brmi R3, 48 ------------- //
            T0_4: begin PCout = 1; MARin = 1; IncPC = 1; Zin = 1; end
            T1_4: begin Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; end
            T2_4: begin MDRout = 1; IRin = 1; end
            
            T3_4: begin Gra = 1; Rout = 1; CONin = 1; end
            T4_4: begin PCout = 1; Yin = 1; end
            T5_4: begin Cout = 1; ADD_op = 1; Zin = 1; end
            T6_4: begin Zlowout = 1; PCin = CON; end
        endcase
    end
endmodule