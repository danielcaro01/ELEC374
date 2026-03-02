// --- tb_div.v ---
`timescale 1ns/10ps
module tb_div;
    // (Same declarations as tb_mul)...
    reg clk, clr, Read, MARin, PCin, MDRin, IRin, Yin, Zin, IncPC;
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, HIin, LOin;
    reg AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op;
    reg [31:0] Mdatain; reg [4:0] BusMuxSel;
    parameter Default=4'b0000, Reg_load1a=4'b0001, Reg_load1b=4'b0010, Reg_load2a=4'b0011, Reg_load2b=4'b0100, T0=4'b0101, T1=4'b0110, T2=4'b0111, T3=4'b1000, T4=4'b1001, T5=4'b1010, T6=4'b1011;
    reg [3:0] Present_state = Default;

    DataPath DUT ( /* Instance Mapping */ );

    initial begin clk=0; forever #10 clk=~clk; end
    always @(posedge clk) begin
        case (Present_state)
            Default: Present_state <= Reg_load1a;   Reg_load1a: Present_state <= Reg_load1b;
            Reg_load1b: Present_state <= Reg_load2a; Reg_load2a: Present_state <= Reg_load2b;
            Reg_load2b: Present_state <= T0;        T0: Present_state <= T1;
            T1: Present_state <= T2;                T2: Present_state <= T3;
            T3: Present_state <= T4;                T4: Present_state <= T5;
            T5: Present_state <= T6;                T6: Present_state <= Default;
        endcase
    end
    always @(*) begin
        {clr, Read, MARin, PCin, MDRin, IRin, Yin, Zin, IncPC, R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, HIin, LOin} = 19'b0;
        {AND_op, OR_op, ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, NEG_op, NOT_op} = 13'b0; BusMuxSel = 5'b0;
        case (Present_state)
            Default: clr = 1;
            Reg_load1a: begin Mdatain=32'h0D; Read=1; MDRin=1; end // 13
            Reg_load1b: begin BusMuxSel=5'd21; R3in=1; end
            Reg_load2a: begin Mdatain=32'h04; Read=1; MDRin=1; end // 4
            Reg_load2b: begin BusMuxSel=5'd21; R1in=1; end
            T0: begin BusMuxSel=5'd20; MARin=1; IncPC=1; Zin=1; end
            T1: begin BusMuxSel=5'd19; PCin=1; Read=1; MDRin=1; Mdatain=32'h0; end
            T2: begin BusMuxSel=5'd21; IRin=1; end
            T3: begin BusMuxSel=5'd3; Yin=1; end
            T4: begin BusMuxSel=5'd1; DIV_op=1; Zin=1; end
            T5: begin BusMuxSel=5'd19; LOin=1; end // Quotient
            T6: begin BusMuxSel=5'd18; HIin=1; end // Remainder
        endcase
    end
endmodule