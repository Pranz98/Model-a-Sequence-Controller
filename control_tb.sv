`timescale 1ns/1ps

module control_test;

    import control_pkg::*;

    logic clk;
    logic rst_;
    opcode_t opcode;
    logic zero;
    logic mem_rd, load_ir, halt, inc_pc, load_ac, load_pc, mem_wr;

    controller dut (
        .clk(clk),
        .rst_(rst_),
        .opcode(opcode),
        .zero(zero),
        .mem_rd(mem_rd),
        .load_ir(load_ir),
        .halt(halt),
        .inc_pc(inc_pc),
        .load_ac(load_ac),
        .load_pc(load_pc),
        .mem_wr(mem_wr)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Testbench stimulus
    initial begin
        rst_ = 0;
        opcode = NOP;
        zero = 0;

        // Reset
        #10;
        rst_ = 1;

        // Test Sequence 1
        @(posedge clk);
        opcode = LDA;
        @(posedge clk);
        @(posedge clk);
        opcode = ADD;
        @(posedge clk);
        @(posedge clk);
        opcode = HLT;
        @(posedge clk);
        @(posedge clk);

        // Test Sequence 2
        rst_ = 0;
        @(posedge clk);
        rst_ = 1;
        opcode = JMP;
        @(posedge clk);
        @(posedge clk);
        opcode = SKZ;
        zero = 1;
        @(posedge clk);
        @(posedge clk);

        // End simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t, clk=%0b, rst_=%0b, opcode=%0b, zero=%0b, mem_rd=%0b, load_ir=%0b, halt=%0b, inc_pc=%0b, load_ac=%0b, load_pc=%0b, mem_wr=%0b",
                 $time, clk, rst_, opcode, zero, mem_rd, load_ir, halt, inc_pc, load_ac, load_pc, mem_wr);
    end

endmodule
