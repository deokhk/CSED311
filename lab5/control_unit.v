`include "opcodes.v"


module ControlUnit (opcode, func_code,

					opcode_out, func_code_out,
					is_branch, is_jmp_jal, is_jpr_jrl,
					mem_read, mem_to_reg, mem_write,
					alu_src, reg_write, pc_to_reg);

	input [3:0] opcode;
	input [5:0] func_code;
	
	output wire [3:0] opcode_out;
	output wire [5:0] func_code_out;
    output wire is_branch;
    output wire is_jmp_jal;
    output wire is_jpr_jrl;
    output wire mem_read;
    output wire mem_to_reg;
    output wire mem_write;
    output wire alu_src;
    output wire reg_write;
    output wire pc_to_reg;

	assign opcode_out = opcode;
	assign func_code_out = func_code;
	assign is_branch = (opcode == `BNE_OP) || (opcode == `BEQ_OP) || (opcode == `BGZ_OP) || (opcode == `BLZ_OP);
    assign is_jmp_jal = (opcode == `JMP_OP) || (opcode == `JAL_OP);
    assign is_jpr_jrl = ((opcode == `JPR_OP) && (func_code == `INST_FUNC_JPR)) || ((opcode == `JRL_OP) && (func_code == `INST_FUNC_JRL));
    assign mem_read = (opcode == `LWD_OP);
    assign mem_to_reg = (opcode == `LWD_OP);
    assign mem_write = (opcode == `SWD_OP);
    assign alu_src = (opcode == `ADI_OP) || (opcode == `ORI_OP) || (opcode == `LHI_OP) || (opcode == `LWD_OP) || (opcode == `SWD_OP);
    assign reg_write = ((opcode == `ADI_OP) || (opcode == `ORI_OP) || (opcode == `LHI_OP) || (opcode == `LWD_OP) || (opcode == `JAL_OP))
					|| ((opcode == `ALU_OP) && (func_code != `INST_FUNC_JPR) && (func_code != `INST_FUNC_WWD) && (func_code != `INST_FUNC_HLT));
    assign pc_to_reg = (opcode == `JAL_OP) || ((opcode == `JRL_OP) && (func_code == `INST_FUNC_JRL));

endmodule


module JorBTakenUnit(is_branch, is_jmp_jal, is_jpr_jrl, bcond,

					 is_j_or_b_taken);

	input is_branch;
	input is_jmp_jal;
	input is_jpr_jrl;
	input bcond;
	
    output wire is_j_or_b_taken;

	assign is_j_or_b_taken = (is_branch && bcond) || (is_jmp_jal || is_jpr_jrl);

endmodule


module PcMuxSelector(is_branch, is_jmp_jal, is_jpr_jrl, bcond,
                        
                     pc_mux_sel);

    input wire is_branch;
    input wire is_jmp_jal;
    input wire is_jpr_jrl;
    input wire bcond;

    output wire [1:0] pc_mux_sel;

    
    assign pc_mux_sel = (is_branch & bcond) ? 2'b00 : (is_jmp_jal ? 2'b01 : (is_jpr_jrl ? 2'b10 : 2'b00));

endmodule
