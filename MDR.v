`timescale 1ns/10ps
module MDR (
    output [31:0] MDRout, 
    input  [31:0] Mdatain, 
    input  [31:0] busMuxOut, 
    input  Read, clr, clock, MDRin
); 
    reg [31:0] mux_out;

    // Phase 1 Figure 4 MUX Logic:
    // If Read = 1, grab data from RAM. Otherwise, grab data from the Bus.
    always @(*) begin
        if (Read)
            mux_out = Mdatain;
        else
            mux_out = busMuxOut;
    end

    // Standard register instantiation to hold the selected data
    register mdr_internal_reg (
        .busMuxIn(MDRout), 
        .busMuxOut(mux_out), 
        .clr(clr), 
        .clock(clock), 
        .Rin(MDRin)
    );
endmodule





//old MDR
/*module MDR (output [31:0] MDRout, input [31:0] Mdatain, busMuxOut, input Read, clr, clock, MDRin);
	reg [31:0] MDRdatain;
	register MDRreg (MDRout, MDRdatain, clr, clock, MDRin)
	
	always @(posedge clk)
		begin
			if(Read == 0) begin
				MDRDatain <= busMuxOut;
			end
			else if(Read == 1) begin
				MDRDatain <= busMuxOut;
			end
		end
endmodule*/
	
	