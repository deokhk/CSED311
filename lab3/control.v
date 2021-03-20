`include "opcodes.v"


module control (opcode,

                is_branch, is_jmp_jal, is_jpr_jrl,
                mem_read, mem_to_reg, mem_write,
                alu_src, reg_write, pc_to_reg);

    input wire [3:0] opcode;

    output reg is_branch;
    output reg is_jmp_jal;
    output reg is_jpr_jrl;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg alu_src;
    output reg reg_write;
    output reg pc_to_reg;

    always @(opcode) begin
        case (opcode)
            `ALU_OP:begin 
                is_branch = 0;
            end

            `ALU_OP:begin 
                is_branch = 0;
            end

            `ALU_OP:begin 
                is_branch = 0;
            end

            default:
        endcase
    end

endmodule


module pc_mux_selector(is_branch, is_jmp_jal, is_jpr_jrl, bcond,
                        
                       pc_mux_sel);

    input wire is_branch;
    input wire is_jmp_jal;
    input wire is_jpr_jrl;
    input wire bcond;

    output reg [1:0] pc_mux_sel;

    always @ (*) begin
        if (is_branch & bcond) 
            pc_mux_sel = 2'b01;
        else if (is_jmp_jal)
            pc_mux_sel = 2'b10;
        else if (is_jpr_jrl)
            pc_mux_sel = 2'b11;
        else
            pc_mux_sel = 2'b00;
    end

endmodule


