`timescale 1ns/10ps
module tb_st;

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
    // MEMORY INITIALIZATION 
    // --------------------------------------------------------
    initial begin
        // TARGET MEMORY INITIALIZATION (As requested by Phase 2 Manual)
        DUT.ram_inst.memory[ 9'h01F ] = 32'h0000_00D4; 
        DUT.ram_inst.memory[ 9'h082 ] = 32'h0000_00A7;

        // CASE 1 Instruction at PC = 0: st 0x1F, R6
        // (Op=0, Ra=6, Rb=0, C=0x1F) -> Hex: 0300001F
        DUT.ram_inst.memory[ 9'h000 ] = 32'h0300001F; 
        
        // CASE 2 Instruction at PC = 1: st 0x1F(R6), R6
        // (Op=0, Ra=6, Rb=6, C=0x1F) -> Hex: 0330001F
        DUT.ram_inst.memory[ 9'h001 ] = 32'h0330001F; 
    end

    // --------------------------------------------------------
    // DELAYED REGISTER PRELOAD (Overrides Reset)
    // --------------------------------------------------------
    initial begin
        // Wait 35ns to safely pass the reset phase and the clock edge
        #35; 
        
        // FORCE the value directly into the hardware register for both cases
        force DUT.R6.Q = 32'h0000_0063;
        
        // Hold the force for 10ns to ensure it latches, then release it
        #10;
        release DUT.R6.Q;
    end

    // --------------------------------------------------------
    // CLOCK & RESET GENERATION
    // --------------------------------------------------------
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    initial begin
        clr = 1; 
        #25 clr = 0; // Held high for 25ns to safely clear the Datapath before FSM starts
    end

    // --------------------------------------------------------
    // SIMULATION DUMP & TIMEOUT
    // --------------------------------------------------------
    initial begin
        $dumpfile("tb_st.vcd"); 
        $dumpvars;
    end

    initial begin
        #127500;
        $display("Simulation complete.");
        $finish;
    end

    // --------------------------------------------------------
    // FSM STATES
    // --------------------------------------------------------
    parameter Default = 5'd0, 
              T0_1=5'd1, T1_1=5'd2, T2_1=5'd3, T3_1=5'd4, T4_1=5'd5, T5_1=5'd6, T6_1=5'd7, T7_1=5'd8, T8_1=5'd9,
              T0_2=5'd10, T1_2=5'd11, T2_2=5'd12, T3_2=5'd13, T4_2=5'd14, T5_2=5'd15, T6_2=5'd16, T7_2=5'd17, T8_2=5'd18;
    reg [ 4:0 ] Present_state = Default;

    always @(posedge clk) begin
        if (clr) Present_state <= Default;
        else begin
            case (Present_state)
                Default: Present_state <= T0_1;
                T0_1: Present_state <= T1_1;
                T1_1: Present_state <= T2_1;
                T2_1: Present_state <= T3_1;
                T3_1: Present_state <= T4_1;
                T4_1: Present_state <= T5_1;
                T5_1: Present_state <= T6_1;
                T6_1: Present_state <= T7_1;
                T7_1: Present_state <= T8_1;
                T8_1: Present_state <= T0_2; // Transitions smoothly to Case 2 after read-back verification

                T0_2: Present_state <= T1_2;
                T1_2: Present_state <= T2_2;
                T2_2: Present_state <= T3_2;
                T3_2: Present_state <= T4_2;
                T4_2: Present_state <= T5_2;
                T5_2: Present_state <= T6_2;
                T6_2: Present_state <= T7_2;
                T7_2: Present_state <= T8_2; 
                T8_2: Present_state <= T8_2; 
            endcase
        end
    end

    // --------------------------------------------------------
    // FSM OUTPUTS
    // --------------------------------------------------------
    always @(Present_state) begin
        // Reset all signals to 0 to prevent inferred latches
        PCout = 0; Zlowout = 0; Zhighout = 0; MDRout = 0; MARin = 0; Zin = 0; PCin = 0; MDRin = 0; 
        IRin = 0; Yin = 0; IncPC = 0; Read = 0; Write = 0; 
        Gra = 0; Grb = 0; Grc = 0; Rin = 0; Rout = 0; BAout = 0; Cout = 0;
        CONin = 0; HIin = 0; LOin = 0; HIout = 0; LOout = 0; InPortout = 0; OutPortin = 0;
        InPort_data_in = 32'b0;
        AND_op = 0; OR_op = 0; ADD_op = 0; SUB_op = 0; MUL_op = 0; DIV_op = 0; SHR_op = 0; 
        SHRA_op = 0; SHL_op = 0; ROR_op = 0; ROL_op = 0; NEG_op = 0; NOT_op = 0;

        case (Present_state)
            // ------------- CASE 1: st 0x1F, R6 ------------- //
            T0_1: begin PCout = 1; MARin = 1; IncPC = 1; Zin = 1; end
            T1_1: begin Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; end
            T2_1: begin MDRout = 1; IRin = 1; end
            
            // Instruction Execution
            T3_1: begin Grb = 1; BAout = 1; Yin = 1; end
            T4_1: begin Cout = 1; ADD_op = 1; Zin = 1; end
            T5_1: begin Zlowout = 1; MARin = 1; end
            T6_1: begin Gra = 1; Rout = 1; MDRin = 1; end // Read R6 to MDR
            T7_1: begin Write = 1; end                    // Write to memory
            T8_1: begin Read = 1; MDRin = 1; end          // VERIFICATION: Read memory back into MDR

            // ---------- CASE 2: st 0x1F(R6), R6 ---------- //
            T0_2: begin PCout = 1; MARin = 1; IncPC = 1; Zin = 1; end
            T1_2: begin Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; end
            T2_2: begin MDRout = 1; IRin = 1; end
            
            // Instruction Execution
            T3_2: begin Grb = 1; BAout = 1; Yin = 1; end
            T4_2: begin Cout = 1; ADD_op = 1; Zin = 1; end
            T5_2: begin Zlowout = 1; MARin = 1; end
            T6_2: begin Gra = 1; Rout = 1; MDRin = 1; end // Read R6 to MDR
            T7_2: begin Write = 1; end                    // Write to memory
            T8_2: begin Read = 1; MDRin = 1; end          // VERIFICATION: Read memory back into MDR
        endcase
    end
endmodule