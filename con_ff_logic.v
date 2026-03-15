`timescale 1ns/10ps

module con_ff_logic (
    input clk,
    input CONin,
    input [1:0] IR_C2,       // Driven by IR(20..19)
    input [31:0] BusMuxOut,  // Evaluates the numerical value of the selected register on the Bus
    output reg CON           // The condition flip-flop output
);

    // Internal wires evaluating the bus state
    wire eq_zero  = ~|BusMuxOut;           // NOR reduction: 1 if all bits are 0
    wire neq_zero =  |BusMuxOut;           // OR reduction: 1 if any bit is 1
    wire positive = ~BusMuxOut[4];        // 1 if MSB is 0 (positive or zero)
    wire negative =  BusMuxOut[4];        // 1 if MSB is 1 (negative)

    reg cond_met;

    // Decode the C2 field to select the proper condition
    always @(*) begin
        case (IR_C2)
            2'b00: cond_met = eq_zero;     // brzr: branch if zero
            2'b01: cond_met = neq_zero;    // brnz: branch if nonzero
            2'b10: cond_met = positive;    // brpl: branch if positive
            2'b11: cond_met = negative;    // brmi: branch if negative
        endcase
    end

    // Synchronous D Flip-Flop with Enable
    always @(posedge clk) begin
        if (CONin) begin
            CON <= cond_met;
        end
    end

endmodule