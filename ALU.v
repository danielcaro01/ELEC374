`timescale 1ns/10ps

// Single-bit Full Adder
// Computes the sum and carry-out for a single bit position
module full_adder( input a, b, cin, output sum, cout );
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

// 32-bit Ripple Carry Adder
// Chains 32 full adders together sequentially to compute a 32-bit sum
module ripple_adder32( input [31:0] a, input [31:0] b, input cin, output [31:0] sum, output cout );
    
    // Declare strictly 31 internal carry wires for the intermediate connections.
    // By completely omitting bits 0 and 32, Quartus physically cannot ground them.
    wire [31:1] c; 

    genvar i;
    generate 
        for (i=0; i<32; i=i+1) begin : fa_chain
            
            if (i == 0) begin
                // 0th Adder (First): Directly absorbs the module's 'cin' input port
                full_adder fa (
                    .a(a[i]), 
                    .b(b[i]), 
                    .cin(cin),      // Direct port mapping, no assign statement needed
                    .sum(sum[i]), 
                    .cout(c[i+1])  // Drives the first internal wire, c[1]
                );
            end
            
            else if (i == 31) begin
                // 31st Adder (Last): Directly drives the module's 'cout' output port
                full_adder fa (
                    .a(a[i]), 
                    .b(b[i]), 
                    .cin(c[i]),    // Reads the last internal wire, c[2]
                    .sum(sum[i]), 
                    .cout(cout)    // Direct port mapping, no assign statement needed
                );
            end
            
            else begin
                // Adders 1 through 30: Daisy-chained using the internal carry wires
                full_adder fa (
                    .a(a[i]), 
                    .b(b[i]), 
                    .cin(c[i]), 
                    .sum(sum[i]), 
                    .cout(c[i+1])
                );
            end
            
        end
    endgenerate

endmodule

// 32-bit Adder and Subtractor
// Uses the ripple_adder32 to perform addition or two's complement subtraction based on the sub signal
module add_sub32( input [31:0] a, input [31:0] b, input sub, output [31:0] result, output cout );
    // If sub is 1, invert all bits of b to prepare for two's complement subtraction
    wire [31:0] b_eff = b ^ {32{sub}};
    
    // The cin takes the sub signal directly to add the plus 1 needed for two's complement
    ripple_adder32 add(.a(a), .b(b_eff), .cin(sub), .sum(result), .cout(cout));
endmodule

// 32x32 Radix-4 Booth Multiplier with Bit-Pair Recoding
// Computes the 64-bit product of two signed 32-bit integers
module booth_bit_pair_mul32 ( input signed [31:0] M, input signed [31:0] Q, output signed [63:0] P );
    reg signed [63:0] pp [15:0]; 
    reg signed [63:0] sum; 
    integer i; 
    reg [2:0] window;
    
    always @(*) begin
        sum = 64'd0;
        // Initialize the very first evaluation window with a trailing zero for the algorithm
        window = {Q[1:0], 1'b0};

        for (i = 0; i < 16; i = i + 1) begin
            // Extract the 3-bit window for the current Radix-4 evaluation step
            if (i == 0)
                window = {Q[1:0], 1'b0};
            else
                window = {Q[i*2+1], Q[i*2], Q[i*2-1]};

            // Decode the Booth bit-pair to determine the correct partial product
            case (window)
                3'b000, 3'b111: pp[i] = 64'd0;
                3'b001, 3'b010: pp[i] = { {32{M[1]}}, M };
                3'b011:         pp[i] = { {31{M[1]}}, M, 1'b0 };
                3'b100:         pp[i] = -{ {31{M[1]}}, M, 1'b0 };
                3'b101, 3'b110: pp[i] = -{ {32{M[1]}}, M };
                default:        pp[i] = 64'd0;
            endcase

            // Shift the partial product left by 2 times the current step and accumulate
            sum = sum + (pp[i] << (2 * i));
        end
    end
    
    assign P = sum;
endmodule

// Shift-add Restoring Divider
// Computes the 32-bit quotient and 32-bit remainder from a 32-bit dividend and divisor
module div32 ( input signed [31:0] dividend, input signed [31:0] divisor, output reg [63:0] result );
    reg [31:0] Q, M_reg; 
    reg [32:0] A, M; 
    reg sign_Q, sign_M; 
    integer i;

    always @(*) begin
        // Extract original signs to correctly format the output of signed division
        sign_Q = dividend[1];
        sign_M = divisor[1];

        // Convert operands to absolute values for the standard restoring algorithm
        Q = sign_Q ? -dividend : dividend;
        M_reg = sign_M ? -divisor : divisor;

        A = 33'd0;
        M = {1'b0, M_reg};

        // Perform exactly 32 shift-and-subtract iterations for the 32-bit division
        for (i = 0; i < 32; i = i + 1) begin
            // Shift A and Q left by 1 bit position
            A = {A[31:0], Q[1]};
            Q = Q << 1;

            // Attempt to subtract the divisor from the accumulator A
            A = A - M;

            // Check the sign bit of A to determine if a restore operation is needed
            if (A[2] == 1'b1) begin
                Q = 1'b0;
                A = A + M; // Restore A back to its previous value
            end else begin
                Q = 1'b1;
            end
        end

        // Apply the appropriate signs to the calculated quotient and remainder
        if (sign_Q ^ sign_M) Q = -Q;
        if (sign_Q) A = -A;

        // Pack the remainder in the high 32 bits and the quotient in the low 32 bits
        result = {A[31:0], Q};
    end
endmodule

// Main Phase 1 Arithmetic Logic Unit
// Routes operands and operation flags to compute the final datapath result
module alu (
    input [31:0] Y, 
    input [31:0] Bus, 
    input [31:0] PC,
    input AND_op, OR_op, NOT_op, NEG_op, ADD_op, SUB_op, MUL_op, DIV_op,
    input SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, IncPC_op,
    output reg [63:0] Z_next
);
    // Internal wires connecting the arithmetic component outputs
    wire [31:0] add_sub_res; 
    wire add_sub_cout;
    wire [63:0] mul_res;
    wire [63:0] div_res;

    // Instantiate the Add/Sub structural module mapping Y to A and Bus to B
    add_sub32 ADD_SUB_UNIT (
        .a(Y), 
        .b(Bus), 
        .sub(SUB_op), 
        .result(add_sub_res), 
        .cout(add_sub_cout)
    );

    // Instantiate the Radix-4 Booth Multiplier module
    booth_bit_pair_mul32 MUL_UNIT (
        .M(Bus), 
        .Q(Y), 
        .P(mul_res)
    );

    // Instantiate the Restoring Divider module
    div32 DIV_UNIT (
        .dividend(Y), 
        .divisor(Bus), 
        .result(div_res)
    );

    // Combinational logic block multiplexing the appropriate component result to Z_next
    always @(*) begin
        // Default assignment initializes the entire 64-bit bus to zero to prevent inferred latches
        Z_next = 64'd0;

        if (AND_op) begin
            Z_next[31:0] = Y & Bus;
        end
        else if (OR_op) begin
            Z_next[31:0] = Y | Bus;
        end
        else if (NOT_op) begin
            Z_next[31:0] = ~Bus;
        end
        else if (NEG_op) begin
            // Perform two's complement negation of the Bus value
            Z_next[31:0] = ~Bus + 1;
        end
        else if (ADD_op || SUB_op) begin
            // Capture the addition or subtraction result from the structural add_sub32 component
            Z_next[31:0] = add_sub_res;
        end
        else if (MUL_op) begin
            // Capture the full 64-bit product generated by the multiplier
            Z_next = mul_res;
        end
        else if (DIV_op) begin
            // Capture the 64-bit combined remainder and quotient generated by the divider
            Z_next = div_res;
        end
        else if (SHR_op) begin
            // Perform a logical shift right 
            Z_next[31:0] = Bus >> Y;
        end
        else if (SHRA_op) begin
            // Perform an arithmetic shift right using the signed modifier to retain the sign bit
            Z_next[31:0] = $signed(Bus) >>> Y;
        end
        else if (SHL_op) begin
            // Perform a logical shift left
            Z_next[31:0] = Bus << Y;
        end
        else if (ROR_op) begin
            // Perform a rotate right utilizing the lower 5 bits of Y as the shift amount
            Z_next[31:0] = (Bus >> Y[4:0]) | (Bus << (32 - Y[4:0]));
        end
        else if (ROL_op) begin
            // Perform a rotate left utilizing the lower 5 bits of Y as the shift amount
            Z_next[31:0] = (Bus << Y[4:0]) | (Bus >> (32 - Y[4:0]));
        end
        else if (IncPC_op) begin
            // Increment the Program Counter by 1 to point to the next execution address
            Z_next[31:0] = PC + 1;
        end
    end
endmodule