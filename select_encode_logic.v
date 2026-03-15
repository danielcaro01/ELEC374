`timescale 1ns/10ps

module select_encode_logic (
    input [31:0] IR,
    input Gra, Grb, Grc,
    input Rin, Rout, BAout,
    output [15:0] R_in,
    output [15:0] R_out,
    output [31:0] C_sign_ext
);
    wire [3:0] dec_in;
    
    // Select Ra (26..23), Rb (22..19), or Rc (18..15) based on Gra, Grb, Grc
    assign dec_in = Gra ? IR[26:23] :
                    Grb ? IR[22:19] :
                    Grc ? IR[18:15] : 4'b0000;

    // 4-to-16 Decoder
    wire [15:0] dec_out;
    assign dec_out = 16'b1 << dec_in;

    // Gate the decoded output with Rin, Rout, and BAout
    assign R_in = dec_out & {16{Rin}};
    assign R_out = dec_out & {16{Rout | BAout}};

    // Sign extend the 19-bit constant C (IR bits 18..0) to 32 bits
    assign C_sign_ext = { {13{IR[7]}}, IR[18:0] };
endmodule