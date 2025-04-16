package control_pkg;
    typedef enum logic [2:0] {
        INST_ADDR = 3'b000,
        INST_FETCH = 3'b001,
        INST_LOAD = 3'b010,
        IDLE = 3'b011,
        OP_ADDR = 3'b100,
        ALU_OP = 3'b101,
        STORE = 3'b110
    } state_t;

    typedef enum logic [2:0] {
        NOP = 3'b000,
        LDA = 3'b001,
        ADD = 3'b010,
        SKZ = 3'b011,
        JMP = 3'b100,
        OUT = 3'b101,
        HLT = 3'b110
    } opcode_t;
endpackage

module controller (
    input logic clk,
    input logic rst_,
    input opcode_t opcode,
    input logic zero,
    output logic mem_rd,
    output logic load_ir,
    output logic halt,
    output logic inc_pc,
    output logic load_ac,
    output logic load_pc,
    output logic mem_wr
);

    import control_pkg::*;

    state_t state, next_state;

    // State Transition Logic (Sequential)
    always_ff @(posedge clk or negedge rst_) begin
        if (~rst_)
            state <= INST_ADDR;
        else
            state <= next_state;
    end

    // Next State Logic (Combinational)
    always_comb begin
        next_state = state;
        case (state)
            INST_ADDR: next_state = INST_FETCH;
            INST_FETCH: next_state = INST_LOAD;
            INST_LOAD: next_state = IDLE;
            IDLE: next_state = (opcode == HLT) ? IDLE : OP_ADDR;
            OP_ADDR: next_state = (opcode == LDA || opcode == ADD) ? ALU_OP : STORE;
            ALU_OP: next_state = STORE;
            STORE: next_state = INST_ADDR;
            default: next_state = INST_ADDR;
        endcase
    end

    // Output Logic (Combinational)
    always_comb begin
        // Default outputs
        mem_rd = 0;
        load_ir = 0;
        halt = 0;
        inc_pc = 0;
        load_ac = 0;
        load_pc = 0;
        mem_wr = 0;

        case (state)
            INST_ADDR: mem_rd = 1;
            INST_FETCH: load_ir = 1;
            INST_LOAD: begin
                if (opcode == HLT) halt = 1;
                else inc_pc = 1;
            end
            ALU_OP: load_ac = (opcode == LDA) || (opcode == ADD);
            STORE: mem_wr = 1;
        endcase
    end

endmodule
