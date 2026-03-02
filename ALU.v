`timescale 1ns/10ps

module full_adder(
    input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module ripple_adder32(
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] sum,
    output cout
);
    wire [32:0] c;
    assign c = cin;
    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : fa_chain
            full_adder fa(.a(a[i]), .b(b[i]), .cin(c[i]), .sum(sum[i]), .cout(c[i+1]));
        end
    endgenerate
    assign cout = c[1];
endmodule

module add_sub32(
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] result,
    output cout
);
    wire [31:0] b_eff = b ^ {32{sub}};
    ripple_adder32 add(.a(a), .b(b_eff), .cin(sub), .sum(result), .cout(cout));
endmodule

// 32x32 Radix-4 Booth Multiplier (Bit-Pair Recoding)
module booth_bit_pair_mul32 (
    input signed [31:0] M,
    input signed [31:0] Q,
    output signed [63:0] P
);
    reg signed [63:0] pp [15:0];
    reg signed [63:0] sum;
    integer i;
    reg [2:0] window;

    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            if (i == 0) window = {Q[1:0], 1'b0};
            else window = Q[i*2+1 -: 3]; 

            case (window)
                3'b000, 3'b111: pp[i] = 0;
                3'b001, 3'b010: pp[i] = M;
                3'b011:         pp[i] = M << 1;
                3'b100:         pp[i] = -(M << 1);
                3'b101, 3'b110: pp[i] = -M;
            endcase
            pp[i] = pp[i] << (2 * i);
        end

        sum = 0;
        for (i = 0; i < 16; i = i + 1) begin
            sum = sum + pp[i];
        end
    end
    assign P = sum;
endmodule

// Shift-add Restoring Divider
module div32 (
    input [31:0] dividend,
    input [31:0] divisor,
    output reg [63:0] result
);
    reg [31:0] Q, M;
    reg [32:0] A;
    integer i;
    
    always @(*) begin
        Q = dividend;
        M = divisor;
        A = 0;
        if (M != 0) begin
            for (i = 0; i < 32; i = i + 1) begin
                A = {A[31:0], Q};
                Q = Q << 1;
                A = A - {1'b0, M};
                if (A[1]) begin // Negative, restore A
                    Q = 0;
                    A = A + {1'b0, M}; 
                end else begin
                    Q = 1;
                end
            end
        end
        result = {A[31:0], Q}; // Remainder in Zhigh, Quotient in Zlow
    end
endmodule

// Main Phase-1 ALU
module alu (
    input [31:0] Y,
    input [31:0] Bus,
    input [31:0] PC,
    input AND_op, OR_op, NOT_op, NEG_op, ADD_op, SUB_op, MUL_op, DIV_op,
    input SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, IncPC_op,
    output reg [63:0] Z_next
);
    wire [31:0] add_sub_res;
    wire add_sub_cout;
    
    wire [31:0] add_a = IncPC_op ? PC : (NEG_op ? 32'b0 : Y);
    wire [31:0] add_b = IncPC_op ? 32'd1 : Bus;
    wire add_sub_ctrl = SUB_op | NEG_op;

    add_sub32 add_sub_unit(
        .a(add_a),
        .b(add_b),
        .sub(add_sub_ctrl),
        .result(add_sub_res),
        .cout(add_sub_cout)
    );

    wire [63:0] mul_res, div_res;
    booth_bit_pair_mul32 mul_unit(.M($signed(Y)), .Q($signed(Bus)), .P(mul_res));
    div32 div_unit(.dividend(Y), .divisor(Bus), .result(div_res));
    
    wire [4:0] shift_amt = Bus[4:0];

    always @(*) begin
        Z_next = 64'b0; 
        if      (AND_op)  Z_next = {32'b0, Y & Bus};
        else if (OR_op)   Z_next = {32'b0, Y | Bus};
        else if (NOT_op)  Z_next = {32'b0, ~Bus};
        else if (ADD_op | SUB_op | NEG_op | IncPC_op)
                          Z_next = {32'b0, add_sub_res};
        else if (MUL_op)  Z_next = mul_res;
        else if (DIV_op)  Z_next = div_res;
        else if (SHR_op)  Z_next = {32'b0, Y >> shift_amt};
        else if (SHRA_op) Z_next = {32'b0, $signed(Y) >>> shift_amt};
        else if (SHL_op)  Z_next = {32'b0, Y << shift_amt};
        else if (ROR_op)  Z_next = {32'b0, (shift_amt==0) ? Y : ((Y >> shift_amt) | (Y << (32 - shift_amt)))};
        else if (ROL_op)  Z_next = {32'b0, (shift_amt==0) ? Y : ((Y << shift_amt) | (Y >> (32 - shift_amt)))};
    end
endmodule