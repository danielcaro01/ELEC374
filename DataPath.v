
//new datapath file
module DataPath (
    input clk, clr, 
    input R0in, R1in, R2in, R5in, R6in, MDRin, // 3-8
    input Read,                               // 9
    input [31:0] Mdatain,                     // 10
    input [4:0] BusMuxSel,                    // 11
    input IRin, Yin, Zin, MARin, PCin,        // 12-16
    input AND, IncPC                          // 17-18
);
    wire [31:0] BusMuxOut;
    wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR5, BusMuxInR6, BusMuxInMDR; 

    // Instantiate Registers
    register R0 (BusMuxInR0, BusMuxOut, clr, clk, R0in);
    register R1 (BusMuxInR1, BusMuxOut, clr, clk, R1in);
    register R2 (BusMuxInR2, BusMuxOut, clr, clk, R2in);
    register R5 (BusMuxInR5, BusMuxOut, clr, clk, R5in);
    register R6 (BusMuxInR6, BusMuxOut, clr, clk, R6in);

    // MDR instance
    MDR mdr_unit (BusMuxInMDR, Mdatain, BusMuxOut, Read, clr, clk, MDRin);

    // Bus instance (Pass 0 to unused inputs for now)
    bus main_bus (
        BusMuxOut, BusMuxSel, 
        BusMuxInR0, BusMuxInR1, BusMuxInR2, 32'h0, 32'h0, 
        BusMuxInR5, BusMuxInR6, 32'h0, 32'h0, 32'h0, 
        32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0,
        32'h0, 32'h0, 32'h0, 32'h0, 32'h0, BusMuxInMDR, 
        32'h0, 32'h0
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
	