module encoder_32to5 ( 
    input [15:0] R_out, 
    input HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout, 
    output reg [4:0] sel 
); 

    always @(*) begin 
        // General Purpose Registers (Indices 0 to 15)
        if      (R_out)  sel = 5'd0; 
        else if (R_out[1])  sel = 5'd1; 
        else if (R_out[2])  sel = 5'd2; 
        else if (R_out[3])  sel = 5'd3; 
        else if (R_out[4])  sel = 5'd4; 
        else if (R_out[5])  sel = 5'd5; 
        else if (R_out[6])  sel = 5'd6; 
        else if (R_out[7])  sel = 5'd7; 
        else if (R_out[8])  sel = 5'd8; 
        else if (R_out[9])  sel = 5'd9; 
        else if (R_out[10]) sel = 5'd10; 
        else if (R_out[11]) sel = 5'd11; 
        else if (R_out[12]) sel = 5'd12; 
        else if (R_out[13]) sel = 5'd13; 
        else if (R_out[14]) sel = 5'd14; 
        else if (R_out[15]) sel = 5'd15; 
        
        // Other Dedicated Registers & Components (Indices 16 to 23)
        else if (HIout)     sel = 5'd16; 
        else if (LOout)     sel = 5'd17; 
        else if (Zhighout)  sel = 5'd18; 
        else if (Zlowout)   sel = 5'd19; 
        else if (PCout)     sel = 5'd20; 
        else if (MDRout)    sel = 5'd21; 
        else if (InPortout) sel = 5'd22; 
        else if (Cout)      sel = 5'd23; 
        
        // Default case to prevent inferred latches
        else                sel = 5'd0; 
    end 
endmodule