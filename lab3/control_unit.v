`include "opcodes.v"


module Control (opcode, func_code,

                is_branch, is_jmp_jal, is_jpr_jrl,
                mem_read, mem_to_reg, mem_write,
                alu_src, reg_write, pc_to_reg);

    input wire [3:0] opcode;
    input wire [5:0] func_code;

    output reg is_branch;
    output reg is_jmp_jal;
    output reg is_jpr_jrl;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg alu_src;
    output reg reg_write;
    output reg pc_to_reg;


    initial begin
        is_branch = 0;
        is_jmp_jal = 0;
        is_jpr_jrl = 0;
        mem_read = 0;
        mem_to_reg = 0;
        mem_write = 0;
        alu_src = 0;
        reg_write = 0;
        pc_to_reg = 0;
    end


    always @(opcode or func_code) begin
        if((opcode == `ALU_OP) || (opcode == `JPR_OP) || (opcode == `JRL_OP)) begin
            if (func_code == `INST_FUNC_JPR) begin
                is_branch = 0;
                is_jmp_jal = 0;
                is_jpr_jrl = 1;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 0;
                pc_to_reg = 0;
            end
            else if (func_code == `INST_FUNC_JRL) begin
                is_branch = 0;
                is_jmp_jal = 0;
                is_jpr_jrl = 1;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 1;
                pc_to_reg = 1;
            end
            else begin
                is_branch = 0;
                is_jmp_jal = 0;
                is_jpr_jrl = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 1;
                pc_to_reg = 0;
            end
        end
        else if ((opcode == `ADI_OP) || (opcode == `ORI_OP) || (opcode == `LHI_OP)) begin
            is_branch = 0;
            is_jmp_jal = 0;
            is_jpr_jrl = 0;
            mem_read = 0;
            mem_to_reg = 0;
            mem_write = 0;
            alu_src = 1;
            reg_write = 1;
            pc_to_reg = 0;
        end
        else if (opcode == `LWD_OP) begin
            is_branch = 0;
            is_jmp_jal = 0;
            is_jpr_jrl = 0;
            mem_read = 1;
            mem_to_reg = 1;
            mem_write = 0;
            alu_src = 1;
            reg_write = 1;
            pc_to_reg = 0;
        end
        else if (opcode == `SWD_OP) begin
            is_branch = 0;
            is_jmp_jal = 0;
            is_jpr_jrl = 0;
            mem_read = 0;
            mem_to_reg = 0;
            mem_write = 1;
            alu_src = 1;
            reg_write = 0;
            pc_to_reg = 0;
        end
        else if ((opcode == `BNE_OP) || (opcode == `BEQ_OP) || (opcode == `BGZ_OP) || (opcode == `BLZ_OP)) begin
            is_branch = 1;
            is_jmp_jal = 0;
            is_jpr_jrl = 0;
            mem_read = 0;
            mem_to_reg = 0;
            mem_write = 0;
            alu_src = 0;
            reg_write = 0;
            pc_to_reg = 0;        
        end
        else if (opcode == `JMP_OP) begin
            is_branch = 0;
            is_jmp_jal = 1;
            is_jpr_jrl = 0;
            mem_read = 0;
            mem_to_reg = 0;
            mem_write = 0;
            alu_src = 0;
            reg_write = 0;
            pc_to_reg = 0;
        end
        else if (opcode == `JAL_OP) begin
            is_branch = 0;
            is_jmp_jal = 1;
            is_jpr_jrl = 0;
            mem_read = 0;
            mem_to_reg = 0;
            mem_write = 0;
            alu_src = 0;
            reg_write = 0;
            pc_to_reg = 1;
        end
        else begin
            is_branch = 0;
            is_jmp_jal = 0;
            is_jpr_jrl = 0;
            mem_read = 0;
            mem_to_reg = 0;
            mem_write = 0;
            alu_src = 0;
            reg_write = 0;
            pc_to_reg = 0;
        end
    end

endmodule


module PcMuxSelector(is_branch, is_jmp_jal, is_jpr_jrl, bcond,
                        
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


