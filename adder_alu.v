
module full_adder(
    input a, b, cin,
    output sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module ripple_adder32(
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);
    wire [32:0] c;
    assign c[0] = cin;

    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : fa_chain
            full_adder fa(.a(a[i]), .b(b[i]), .cin(c[i]), .sum(sum[i]), .cout(c[i+1]));
        end
    endgenerate

    assign cout = c[32];
endmodule

// add_sub: sub=0 => a+b ; sub=1 => a-b (two's complement)
module add_sub32(
    input  [31:0] a,
    input  [31:0] b,
    input         sub,
    output [31:0] result,
    output        cout
);
    wire [31:0] b_eff = b ^ {32{sub}};
    ripple_adder32 add(.a(a), .b(b_eff), .cin(sub), .sum(result), .cout(cout));
endmodule

module alu32_min(
    input  [31:0] y,
    input  [31:0] bus,
    input         AND_op,
    input         IncPC_op,
    input  [31:0] pc,
    output [63:0] z_next
);
    wire [31:0] pc_plus1;
    wire pc_cout;
    ripple_adder32 pcadd(.a(pc), .b(32'h0000_0001), .cin(1'b0), .sum(pc_plus1), .cout(pc_cout));

    wire [31:0] and_res = y & bus;

    // Priority: IncPC over AND (matches your TB usage: they never assert both)
    assign z_next = IncPC_op ? {32'h0, pc_plus1} :
                    AND_op   ? {32'h0, and_res}   :
                              {32'h0, bus}; // safe default
endmodule
