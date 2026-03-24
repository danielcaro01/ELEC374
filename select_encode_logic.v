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

    // 1. Mux to choose which register field to decode based on Gra, Grb, Grc
    // Mini SRC Fields: Ra = IR[26:23], Rb = IR[22:19], Rc = IR[18:15]
    assign dec_in = Gra ? IR[26:23] :
                    Grb ? IR[22:19] :
                    Grc ? IR[18:15] : 4'b0000;

    // 2. Decode the 4-bit input into a 16-bit one-hot wire
    wire [15:0] dec_out;
    assign dec_out = 16'b1 << dec_in;

    // 3. Drive the R_in bus
    assign R_in = Rin ? dec_out : 16'b0;

    // 4. Drive the R_out bus (THE FIX FOR YOUR BUG)
    // BAout must trigger the R_out bus exactly like Rout does!
    assign R_out = (Rout | BAout) ? dec_out : 16'b0;

    // 5. Sign extend the 19-bit constant C (IR[18:0]) to 32 bits
    assign C_sign_ext = { {13{IR[ 18 ]}}, IR[ 18:0 ] };

endmodule