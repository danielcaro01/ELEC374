
`timescale 1ns/10ps
module datapath_tb;
    reg clk, clr;
    reg R0in, R1in, R2in, R5in, R6in, MDRin, IRin, Yin, Zin, MARin, PCin;
    reg [31:0] Mdatain;
    reg [4:0] BusMuxSel;
    reg Read, AND, IncPC;

    parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, 
              Reg_load2a = 4'b0011, Reg_load2b = 4'b0100, Reg_load3a = 4'b0101, 
              Reg_load3b = 4'b0110, T0 = 4'b0111, T1 = 4'b1000, T2 = 4'b1001, 
              T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100;
              
    reg [3:0] Present_state = Default;

   DataPath DUT (
        clk, clr, R0in, R1in, R2in, R5in, R6in, MDRin, // 1-8
        Read, Mdatain, BusMuxSel,                      // 9-11
        IRin, Yin, Zin, MARin, PCin,                   // 12-16
        AND, IncPC                                     // 17-18
    );

    initial begin
        $dumpfile("datapath_sim.vcd");
        $dumpvars(0, datapath_tb);
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Safety termination to prevent 14GB files
    initial begin
        #500 $finish; 
    end

    always @(posedge clk) begin
        case (Present_state)
            Default:    Present_state <= Reg_load1a;
            Reg_load1a: Present_state <= Reg_load1b;
            Reg_load1b: Present_state <= Reg_load2a;
            Reg_load2a: Present_state <= Reg_load2b;
            Reg_load2b: Present_state <= T0;
            T0:         Present_state <= T1;
            T1:         Present_state <= T2;
            T2:         Present_state <= T3;
            T3:         Present_state <= T4;
            T4:         Present_state <= T5;
            T5:         Present_state <= Default;
        endcase
    end

    always @(Present_state) begin
        {R0in, R1in, R2in, R5in, R6in, MDRin, IRin, Yin, Zin, MARin, PCin} = 11'b0;
        {Read, AND, IncPC} = 3'b0;
        BusMuxSel = 5'b0;
        case (Present_state)
            Default: clr = 1;
            Reg_load1a: begin Mdatain = 32'h34; Read = 1; MDRin = 1; end
            Reg_load1b: begin BusMuxSel = 5'd21; R5in = 1; end
            Reg_load2a: begin Mdatain = 32'h45; Read = 1; MDRin = 1; end
            Reg_load2b: begin BusMuxSel = 5'd21; R6in = 1; end
            T0: begin BusMuxSel = 5'd20; MARin = 1; IncPC = 1; Zin = 1; end
            T1: begin BusMuxSel = 5'd19; PCin = 1; Read = 1; MDRin = 1; Mdatain = 32'h112B0000; end
            T2: begin BusMuxSel = 5'd21; IRin = 1; end
            T3: begin BusMuxSel = 5'd5; Yin = 1; end
            T4: begin BusMuxSel = 5'd6; AND = 1; Zin = 1; end
            T5: begin BusMuxSel = 5'd19; R2in = 1; end
        endcase
    end
endmodule
//old testbench file
/*
// and datapath_tb.v file: <This is the filename>
`timescale 1ns/10ps
module datapath_tb;
	reg R0in, R1in, R2in;
	reg Clock, clr
	reg [31:0] Mdatain;
	
	parameter	Default = 4’b0000, Reg_load1a = 4’b0001, Reg_load1b = 4’b0010, Reg_load2a = 4’b0011,
					Reg_load2b = 4’b0100, Reg_load3a = 4’b0101, Reg_load3b = 4’b0110, T0 = 4’b0111,
					T1 = 4’b1000, T2 = 4’b1001, T3 = 4’b1010, T4 = 4’b1011, T5 = 4’b1100;
	reg [3:0] Present_state = Default;
	
	Datapath DUT(clk, clr, R0in, R1in, R2in, Mdatain, BusMuxSel)
	
// add test logic here
initial
	begin
		Clock = 0;
		forever #10 Clock = ~ Clock;
end
always @(posedge Clock) // finite state machine; if clock rising-edge
	begin
		case (Present_state)
			Default		:	Present_state = Reg_load1a;
			Reg_load1 	: 	Present_state = Reg_load1b;
			Reg_load2 	: Present_state = Reg_load2a;
			Reg_load3 	: Present_state = Reg_load2b;
endcase

always @(Present_state) // do the required job in each state
	begin
		case (Present_state) // assert the required signals in each clock cycle
			Default: begin
				PCout <= 0; Zlowout <= 0; MDRout <= 0; // initialize the signals
				R3out <= 0; R7out <= 0; MARin <= 0; Zin <= 0;
				PCin <=0; MDRin <= 0; IRin <= 0; Yin <= 0;
				IncPC <= 0; Read <= 0; AND <= 0;
				R2in <= 0; R5in <= 0; R6in <= 0; Mdatain <= 32’h00000000;
			end
			Reg_load1: begin
				Mdatain <= 32’h00000034;
				Read = 0; MDRin = 0; // the first zero is there for completeness
				Read <= 1; MDRin <= 1; // Took out #15 for '1', as it may not be needed
				#15 Read <= 0; MDRin <= 0; // for your current implementation
			end
			Reg_load2: begin
				MDRout <= 1; R5in <= 1;
				#15 MDRout <= 0; R5in <= 0; // initialize R5 with the value 0x34
			end
			Reg_load3: begin
				Mdatain <= 32’h00000045;
				Read <= 1; MDRin <= 1;
				#15 Read <= 0; MDRin <= 0;
			end
			Reg_load2b: begin
				MDRout <= 1; R6in <= 1;
				#15 MDRout <= 0; R6in <= 0; // initialize R6 with the value 0x45
			end
			Reg_load3a: begin
				Mdatain <= 32’h00000067;
				Read <= 1; MDRin <= 1;
				#15 Read <= 0; MDRin <= 0;
			end
			Reg_load3b: begin
				MDRout <= 1; R2in <= 1;
				#15 MDRout <= 0; R2in <= 0; // initialize R2 with the value 0x67
			end
			T0: begin // see if you need to de-assert these signals
				PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
			end
			T1: begin
				Zlowout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
				Mdatain <= 32’h112B0000; // opcode for “and R2, R5, R6”
			end
			T2: begin
				MDRout <= 1; IRin <= 1;
			end
			T3: begin
				R5out <= 1; Yin <= 1;
			end
			T4: begin
				R6out <= 1; AND <= 1; Zin <= 1;
			end
			T5: begin
				Zlowout <= 1; R2in <= 1;
			end
		endcase
	end
endmodule 

*/