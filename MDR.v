


// new MDR.v
module MDR (output [31:0] MDRout, input [31:0] Mdatain, busMuxOut, input Read, clr, clock, MDRin);
    reg [31:0] MDRDatain; 
    
    
    register MDRreg (MDRout, MDRDatain, clr, clock, MDRin);
    
    always @(*) 
    begin
        if(Read == 1'b1) begin
            MDRDatain = Mdatain; 
        end
        else begin
            MDRDatain = busMuxOut; 
        end
    end
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
	
	
