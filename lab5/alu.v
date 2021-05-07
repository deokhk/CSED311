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
			
			alu_result, overflow_flag, bcond);

	input [`WORD_SIZE-1:0] alu_input_1;
	input [`WORD_SIZE-1:0] alu_input_2;
    input wire [3:0] opcode;
    input wire [5:0] func_code;

	output reg [`WORD_SIZE-1:0] alu_result;
	output reg overflow_flag; 
	output reg bcond;

	wire [`NumBits - 1: 0] add_out;
	wire [`NumBits - 1: 0] sub_out;

	wire [`NumBits - 1: 0] not_out;
	wire [`NumBits - 1: 0] and_out;
	wire [`NumBits - 1: 0] orr_out;

	wire [`NumBits - 1: 0] tcp_out;
	wire [`NumBits - 1: 0] shl_out;
	wire [`NumBits - 1: 0] shr_out;

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


	initial begin
		alu_result = 0;
		bcond = 0;
        overflow_flag = 0;
	end

	always @(*) begin
		case (opcode)
			`ALU_OP:begin
				case (func_code)
					`INST_FUNC_ADD:begin alu_result = add_out; bcond = 0; overflow_flag = add_flag; end
					`INST_FUNC_SUB:begin alu_result = sub_out; bcond = 0; overflow_flag = sub_flag; end
					`INST_FUNC_AND:begin alu_result = and_out; bcond = 0; overflow_flag = 0; end
					`INST_FUNC_ORR:begin alu_result = orr_out; bcond = 0; overflow_flag = 0; end
					`INST_FUNC_NOT:begin alu_result = not_out; bcond = 0; overflow_flag = 0; end
					`INST_FUNC_TCP:begin alu_result = tcp_out; bcond = 0; overflow_flag = 0; end
					`INST_FUNC_SHL:begin alu_result = shl_out; bcond = 0; overflow_flag = 0; end
					`INST_FUNC_SHR:begin alu_result = shr_out; bcond = 0; overflow_flag = 0; end
					`INST_FUNC_JPR:begin alu_result = 0; bcond = 0; overflow_flag = 0; end // pc <- rs 는 따로 해줌, 
					`INST_FUNC_JRL:begin alu_result = 0; bcond = 0; overflow_flag = 0; end // pc <- rs 는 따로 해줌, $2 = PC+1 도 따로 해줌.
					`INST_FUNC_WWD:begin alu_result = 0; bcond = 0; overflow_flag = 0; end
					`INST_FUNC_HLT:begin alu_result = 0; bcond = 0; overflow_flag = 0; end
					default:begin alu_result = 0; bcond = 0; overflow_flag = 0; end
				endcase
			end

			// Bxx 연산들의 pc + offset 은 다른 Adder 에서.
			`BNE_OP:begin alu_result = 0;  bcond = (alu_input_1 != alu_input_2); overflow_flag = 0; end
			`BEQ_OP:begin alu_result = 0;  bcond = (alu_input_1 == alu_input_2); overflow_flag = 0; end
			`BGZ_OP:begin alu_result = 0;  bcond = ($signed(alu_input_1) > 0); overflow_flag = 0; end
			`BLZ_OP:begin alu_result = 0;  bcond = ($signed(alu_input_1) < 0); overflow_flag = 0; end

			`ADI_OP:begin alu_result = add_out; bcond = 0; overflow_flag = add_flag; end
			`ORI_OP:begin alu_result = orr_out; bcond = 0; overflow_flag = 0; end
			`LHI_OP:begin alu_result = alu_input_2; bcond = 0; overflow_flag = 0; end
			`LWD_OP:begin alu_result = add_out; bcond = 0; overflow_flag = add_flag; end
			`SWD_OP:begin alu_result = add_out; bcond = 0; overflow_flag = add_flag; end

			`JMP_OP:begin alu_result = 0; bcond = 0; overflow_flag = 0; end // PC <- extended output 따로 해줌
			`JAL_OP:begin alu_result = 0; bcond = 0; overflow_flag = 0; end // PC <- extended output 따로 해줌. $2 = PC+1 도 wb_mux 에서 따로 해줌.

			default:begin alu_result = 0; bcond = 0; overflow_flag = 0; end
		endcase
	end

endmodule