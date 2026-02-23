module bus (
    output [31:0] BusMuxOut,
    input [4:0] sel, // From DataPath [cite: 584]
    input [31:0] R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, // 
    input [31:0] R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,
    input [31:0] HIin, LOin, Zhighin, Zlowin,
    input [31:0] PCin, MDRin, InPort, C_sign_extin
);
    reg [31:0] q;
    
    always @ (*) begin
        case (sel) // [cite: 592]
            5'd0:  q = R0in;
            5'd1:  q = R1in;
            5'd2:  q = R2in;
            5'd3:  q = R3in; // [cite: 593]
            5'd4:  q = R4in;
            5'd5:  q = R5in;
            5'd6:  q = R6in;
            5'd7:  q = R7in; // [cite: 593]
            5'd8:  q = R8in; // [cite: 594]
            5'd9:  q = R9in;
            5'd10: q = R10in;
            5'd11: q = R11in;
            5'd12: q = R12in; // [cite: 594]
            5'd13: q = R13in; // [cite: 595]
            5'd14: q = R14in;
            5'd15: q = R15in; // [cite: 595]
            5'd16: q = HIin;
            5'd17: q = LOin;
            5'd18: q = Zhighin; // [cite: 596]
            5'd19: q = Zlowin;
            5'd20: q = PCin;
            5'd21: q = MDRin;
            5'd22: q = InPort; // [cite: 596]
            5'd23: q = C_sign_extin; // [cite: 597]
            default: q = 32'h0000_0000;
        endcase
    end

    assign BusMuxOut = q;
endmodule


//old bus file
/*module bus (output BusMuxOut, 
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
		
*/