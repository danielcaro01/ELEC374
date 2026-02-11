module bus (output BusMuxOut, 
				input R0out, R1out, R2out, R3out, R4out, 
				R5out, R6out, R7out, R8out, R9out, 
				R10out, R11out, R12out, R13out, R14out,
				R15out, HIout, LOout, Zhighout, Zlowout,
				PCout, MDRout, InPortout, Cout,
				input [31:0] R0in, R1in, R2in, R3in, R4in,
				R5in, R6in, R7in, R8in, R9in, 
				R10in, R11in, R12in, R13in, R14in,
				R15in, HIin, LOin, Zhighin, Zlowin,
				PCin, MDRin, InPort, C_sign_extin);
	
	reg [31:0] q;
	
	always @ (*) begin
		
		case (sel)
			5'b00000: q <= R0in;
			5'b00001: q <= R1in;
			5'b00010: q <= R2in;
			5'b00011: q <= R3in;
			5'b00100: q <= R4in;
			5'b00101: q <= R5in;
			5'b00110: q <= R6in;
			5'b00111: q <= R7in;
			5'b01000: q <= R8in;
			5'b01001: q <= R9in;
			5'b01010: q <= R10in;
			5'b01011: q <= R11in;
			5'b01100: q <= R12in;
			5'b01101: q <= R13in;
			5'b01110: q <= R14in;
			5'b01111: q <= R15in;
			5'b10000: q <= HIin;
			5'b10001: q <= LOin;
			5'b10010: q <= Zhighin;
			5'b10011: q <= Zlowin;
			5'b10100: q <= PCin;
			5'b10101: q <= MDRin;
			5'b10110: q <= InPort;
			5'b10111: q <= C_sign_extin;
			default: BusMuxOut = 32'h0000_0000;
		end case;
	end
assign BusMuxOut = q;
endmodule;
		
		