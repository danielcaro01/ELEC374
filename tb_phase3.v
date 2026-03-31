`timescale 1ns/10ps
module tb_phase3;

    reg clk;
    reg reset;
    reg stop;
    reg [31:0] InPort_data_in;

    wire [31:0] OutPort_data_out;
    wire [31:0] PC_out, IR_out, MAR_out, MDR_out, HI_out, LO_out, Zhigh_out, Zlow_out;
    wire [31:0] R0_out, R1_out, R2_out, R3_out, R4_out, R5_out, R6_out, R7_out;
    wire [31:0] R8_out, R9_out, R10_out, R11_out, R12_out, R13_out, R14_out, R15_out;

    DataPath DUT (
        .clk(clk),
        .reset(reset),
        .stop(stop),
        .InPort_data_in(InPort_data_in),
        .OutPort_data_out(OutPort_data_out),
        .PC_out(PC_out), .IR_out(IR_out), .MAR_out(MAR_out), .MDR_out(MDR_out),
        .HI_out(HI_out), .LO_out(LO_out), .Zhigh_out(Zhigh_out), .Zlow_out(Zlow_out),
        .R0_out(R0_out), .R1_out(R1_out), .R2_out(R2_out), .R3_out(R3_out),
        .R4_out(R4_out), .R5_out(R5_out), .R6_out(R6_out), .R7_out(R7_out),
        .R8_out(R8_out), .R9_out(R9_out), .R10_out(R10_out), .R11_out(R11_out),
        .R12_out(R12_out), .R13_out(R13_out), .R14_out(R14_out), .R15_out(R15_out)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_phase3.vcd");
        $dumpvars(0, tb_phase3);

        InPort_data_in = 32'h00000000;
        stop = 0;

        // Load the hex file and initialize required memory addresses directly in the testbench [1].
        $readmemh("program.hex", DUT.RAM.memory);
        
        // Initialize memory locations 0x89 and 0xA3 with the 32-bit hexadecimal values 0xA7 and 0x68, respectively [2].
        DUT.RAM.memory[9'h089] = 32'h000000A7; 
        DUT.RAM.memory[9'h0A3] = 32'h00000068; 

        reset = 1;
        #25;

        reset = 0;

        #127500;

        $display("Simulation complete.");
        $finish;
    end
endmodule