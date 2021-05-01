`include "opcodes.v"

module HazardDetection(rs1_addr_id, rs2_addr_id,
					 opcode, func_code,
					rd_addr_ex, mem_read_ex

					is_stall
);

	input wire [1:0] rs1_id_addr;
	input wire [1:0] rs2_id_addr;
	input wire [3:0] opcode;
	input wire [5:0] func_code;
	input wire [1:0] rd_ex_addr;
	input wire mem_read_ex

	output is_stall;

	wire use_rs1_id;
	wire use_rs2_id;

	assign use_rs1_id = (opcode == `ALU_OP) || (opcode == `ADI_OP) || (opcode == `ORI_OP)
					 || (opcode == `LWD_OP) || (opcode == `SWD_OP)
					 || (opcode == `BNE_OP) || (opcode == `BEQ_OP) || (opcode == `BGZ_OP) || (opcode == `BLZ_OP);

	assign use_rs2_id = (opcode == `SWD_OP) || (opcode == `BNE_OP) || (opcode == `BEQ_OP) 
					 || ((opcode == `ALU_OP) && (func_code == `INST_FUNC_ADD)) // ADD
					 || ((opcode == `ALU_OP) && (func_code == `INST_FUNC_SUB)) // SUB
					 || ((opcode == `ALU_OP) && (func_code == `INST_FUNC_AND)) // AND
					 || ((opcode == `ALU_OP) && (func_code == `INST_FUNC_ORR)); // ORR
					 
	assign is_stall = (((rs1_id_addr == rd_ex_addr) && use_rs1_id) || ((rs2_id_addr == rd_ex_addr) && use_rs2_id)) && mem_read_ex;

endmodule

