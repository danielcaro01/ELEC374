`timescale 1ns/10ps
module tb_div;

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
        // div R3, R1
        // R-Format: Op=12 (01100), Ra=3 (0011), Rb=1 (0001), Unused=0
        // Binary: 0110_0001_1000_1000_0000_0000_0000_0000 -> Hex: 61880000
        DUT.ram_inst.memory[ 9'h000 ] = 32'h61880000; 
    end

    // --------------------------------------------------------
    // DELAYED REGISTER PRELOAD
    // --------------------------------------------------------
    initial begin
        // Safely wait for reset to finish
        #35; 
        
        // Preload registers for the division: 25 / 4
        // R3 = 25 (Dividend), R1 = 4 (Divisor)
        force DUT.R3.Q = 32'd25;
        force DUT.R1.Q = 32'd4;
        #10; 
        release DUT.R3.Q;
        release DUT.R1.Q;
    end

    // --------------------------------------------------------
    // CLOCK & RESET GENERATION
    // --------------------------------------------------------
    initial begin clk = 0; forever #10 clk = ~clk; end
    initial begin clr = 1; #25 clr = 0; end

    // --------------------------------------------------------
    // SIMULATION DUMP & TIMEOUT
    // --------------------------------------------------------
    initial begin $dumpfile("tb_div.vcd"); $dumpvars; end
    initial begin #127500; $display("Simulation complete."); $finish; end

    // --------------------------------------------------------
    // FSM STATES
    // --------------------------------------------------------
    parameter Default = 5'd0, 
              T0=5'd1, T1=5'd2, T2=5'd3, T3=5'd4, T4=5'd5, T5=5'd6, T6=5'd7;
    reg [ 4:0 ] Present_state = Default;

    always @(posedge clk) begin
        if (clr) Present_state <= Default;
        else case (Present_state)
            Default: Present_state <= T0;
            T0: Present_state <= T1;
            T1: Present_state <= T2;
            T2: Present_state <= T3;
            T3: Present_state <= T4;
            T4: Present_state <= T5;
            T5: Present_state <= T6;
            T6: Present_state <= T6;
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
            // ------------- div R3, R1 ------------- //
            T0: begin PCout = 1; MARin = 1; IncPC = 1; Zin = 1; end
            T1: begin Zlowout = 1; PCin = 1; Read = 1; MDRin = 1; end
            T2: begin MDRout = 1; IRin = 1; end
            
            T3: begin Gra = 1; Rout = 1; Yin = 1; end // Dump R3 (Dividend) into Y
            T4: begin Grb = 1; Rout = 1; DIV_op = 1; Zin = 1; end // Divide Y by R1 (Divisor)
            T5: begin Zlowout = 1; LOin = 1; end // Store Quotient in LO
            T6: begin Zhighout = 1; HIin = 1; end // Store Remainder in HI
        endcase
    end
endmodule