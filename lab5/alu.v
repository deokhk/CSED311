`include "opcodes.v" 
`include "module_add_sub.v"
`include "module_bitwise.v"
`include "module_others.v"

// 원하는 것:
// Bxx: extended_output + 1 이 next_pc_candidate
// JAL: $2 = PC+1. pc <- extended_output
// JRL: $2 = PC+1. pc <- rs

// Bxx -> PC + offset + 1 (with distinct Adder)
// JMP: PC <- extended output
// JAL: $2 = PC+1. PC <- extended output
// JPR: PC <- rs
// JRL: $2 = PC+1. PC <- rs

// PC MUX
// 0: Bxx. pc + offset + 1 (with distinct Adder)
// 1: JMP, JAL: extended_output_ex 그대로.
// 2: JPR, JRL: rs 그대로

module ALU (alu_input_1, alu_input_2, opcode, func_code,
			
			alu_result, bcond);

	input [`WORD_SIZE-1:0] alu_input_1;
	input [`WORD_SIZE-1:0] alu_input_2;
    input wire [3:0] opcode;
    input wire [5:0] func_code;

	output wire [`WORD_SIZE-1:0] alu_result;
	output wire bcond;

	wire [`NumBits - 1: 0] add_out;
	wire [`NumBits - 1: 0] sub_out;

	wire [`NumBits - 1: 0] not_out;
	wire [`NumBits - 1: 0] and_out;
	wire [`NumBits - 1: 0] orr_out;

	wire [`NumBits - 1: 0] tcp_out;
	wire [`NumBits - 1: 0] shl_out;
	wire [`NumBits - 1: 0] shr_out;

	// wire overflow_flag;

    wire add_flag;
    wire sub_flag;


	ADDModule add_module (
		.A(alu_input_1), .B(alu_input_2), 
		.C(add_out), .OverflowFlag(add_flag)
	);
	SUBModule sub_module (
		.A(alu_input_1), .B(alu_input_2),
		.C(sub_out), .OverflowFlag(sub_flag)
	);


	NOTModule not_module (
		.A(alu_input_1),
		.C(not_out)
	);
	ANDModule and_module (
		.A(alu_input_1), .B(alu_input_2),
		.C(and_out)
	);
	ORRModule orr_module (
		.A(alu_input_1), .B(alu_input_2),
		.C(orr_out)
	);


	TCPModule tcp_module (
		.A(alu_input_1), 
		.C(tcp_out)
	);
	SHLModule als_module (
		.A(alu_input_1), 
		.C(shl_out)
	);
	SHRModule ars_module (
		.A(alu_input_1), 
		.C(shr_out)
	);

	assign alu_result = (opcode == `ALU_OP) && (func_code == `INST_FUNC_ADD) ? add_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_SUB) ? sub_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_AND) ? and_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_ORR) ? orr_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_NOT) ? not_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_TCP) ? tcp_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_SHL) ? shl_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_SHR) ? shr_out
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_JPR) ? 0
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_JRL) ? 0
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_WWD) ? 0
					  : (opcode == `ALU_OP) && (func_code == `INST_FUNC_HLT) ? 0
					  : (opcode == `BNE_OP) ? 0
					  : (opcode == `BEQ_OP) ? 0
					  : (opcode == `BGZ_OP) ? 0
					  : (opcode == `BLZ_OP) ? 0
					  : (opcode == `ADI_OP) ? add_out
					  : (opcode == `ORI_OP) ? orr_out
					  : (opcode == `LHI_OP) ? alu_input_2
					  : (opcode == `LWD_OP) ? add_out
					  : (opcode == `SWD_OP) ? add_out
					  : (opcode == `JMP_OP) ? 0
					  : (opcode == `JAL_OP) ? 0
					  : 0;
	
	assign bcond = (opcode == `BNE_OP) ? (alu_input_1 != alu_input_2)
				 : (opcode == `BEQ_OP) ? (alu_input_1 == alu_input_2)
				 : (opcode == `BGZ_OP) ? ($signed(alu_input_1) > 0)
				 : (opcode == `BLZ_OP) ? ($signed(alu_input_1) < 0)
				 : 0;

endmodule
