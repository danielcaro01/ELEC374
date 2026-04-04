`timescale 1ns/10ps

// Select and Encode Logic: Decodes the Instruction Register (IR) fields to route
// control signals to the correct general-purpose registers and sign-extends constants.
module select_encode_logic (
    input [31:0] IR,
    input Gra, Grb, Grc,
    input Rin, Rout, BAout,
    output [15:0] R_in,
    output [15:0] R_out,
    output [31:0] C_sign_ext
);

    wire [3:0] dec_in;
    wire [15:0] dec_out;

    // Multiplexer to extract the 4-bit register operand field from the Instruction Register.
    // Gra routes Ra (bits 26:23), Grb routes Rb (bits 22:19), Grc routes Rc (bits 18:15).
    assign dec_in = Gra ? IR[26:23] :
                    Grb ? IR[22:19] :
                    Grc ? IR[18:15] : 4'b0000;

    // 4-to-16 Decoder translates the 4-bit operand into a 16-bit one-hot register selection vector.
    assign dec_out = 16'd1 << dec_in;

    // Route the global Rin control signal strictly to the input enable of the chosen register.
    assign R_in = {16{Rin}} & dec_out;

    // Route the global Rout or BAout control signal strictly to the output enable of the chosen register.
    // (If R0 is selected during BAout, the register_r0 module physically intercepts it to output 0x0).
    assign R_out = {16{Rout | BAout}} & dec_out;

    // Sign-extend the 19-bit immediate constant C (IR[18:0]) to a full 32 bits.
    // IR[1] is the sign bit, physically replicated 13 times to pad the upper integer boundary.
    assign C_sign_ext = { {13{IR[1]}}, IR[18:0] };

endmodule