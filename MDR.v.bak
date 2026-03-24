


// Recommended MDR.v
module MDR (output [31:0] MDRout, input [31:0] Mdatain, busMuxOut, input Read, clr, clock, MDRin);
    reg [31:0] MDRDatain; // Corrected casing to match your usage below
    
    // Internal register instance 
    register MDRreg (MDRout, MDRDatain, clr, clock, MDRin);
    
    always @(*) // Combinational logic for the input mux [cite: 192]
    begin
        if(Read == 1'b1) begin
            MDRDatain = Mdatain; // Select memory input [cite: 201, 202]
        end
        else begin
            MDRDatain = busMuxOut; // Select bus input [cite: 200, 202]
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
	
	