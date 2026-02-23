//regiisters new

module register #(parameter size = 32)(
    output [size-1:0] busMuxIn, // Added bit range [cite: 102, 116]
    input [size-1:0] busMuxOut, // Added bit range [cite: 102]
    input clr, clock, Rin
);
	reg [size-1:0] Q;

	always @(posedge clock) // Changed 'clk' to 'clock' to match input port [cite: 112]
		begin
			if(clr) begin
				Q <= {size{1'b0}}; // Synchronous reset [cite: 106, 109]
			end
			else if(Rin) begin
				Q <= busMuxOut; // Load from bus when Rin is high [cite: 103, 104]
			end
		end
        
	assign busMuxIn = Q; // Fixed 'q' to 'Q' to match register name [cite: 115]
endmodule


//registers old
/*module register #(parameter size = 32)(output busMuxIn, input busMuxOut, clr, clock, Rin);
	reg [size-1:0] Q;
	
	always @(posedge clk)
		begin
			if(clr) begin
				Q <= {size{1'b0}};
			end
			else if(Rin) begin
				Q <= busMuxOut;
			end
		end
	assign busMuxIn = q[size-1:0];
endmodule*/
			
	

	