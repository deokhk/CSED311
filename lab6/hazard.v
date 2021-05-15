`include "opcodes.v"


module HazardDetection(rs1_addr_id, rs2_addr_id,
					   opcode_id, func_code_id,
					   rd_addr_ex, mem_read_ex,

					   is_stall
);

	input wire [1:0] rs1_addr_id;
	input wire [1:0] rs2_addr_id;
	input wire [3:0] opcode_id;
	input wire [5:0] func_code_id;
	input wire [1:0] rd_addr_ex;
	input wire mem_read_ex;

	output is_stall;

	wire use_rs1_id;
	wire use_rs2_id;

	assign use_rs1_id = (opcode_id == `ALU_OP) || (opcode_id == `ADI_OP) || (opcode_id == `ORI_OP)
					 || (opcode_id == `LWD_OP) || (opcode_id == `SWD_OP)
					 || (opcode_id == `BNE_OP) || (opcode_id == `BEQ_OP) || (opcode_id == `BGZ_OP) || (opcode_id == `BLZ_OP);

	assign use_rs2_id = (opcode_id == `SWD_OP) || (opcode_id == `BNE_OP) || (opcode_id == `BEQ_OP) 
					 || ((opcode_id == `ALU_OP) && (func_code_id == `INST_FUNC_ADD)) // ADD
					 || ((opcode_id == `ALU_OP) && (func_code_id == `INST_FUNC_SUB)) // SUB
					 || ((opcode_id == `ALU_OP) && (func_code_id == `INST_FUNC_AND)) // AND
					 || ((opcode_id == `ALU_OP) && (func_code_id == `INST_FUNC_ORR)); // ORR
					 
	assign is_stall = (((rs1_addr_id == rd_addr_ex) && use_rs1_id) || ((rs2_addr_id == rd_addr_ex) && use_rs2_id)) && mem_read_ex;

endmodule

