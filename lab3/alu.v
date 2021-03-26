`include "opcodes.v"
`include "module_add_sub.v"
`include "module_bitwise.v"
`include "module_others.v"


`define	NumBits	16


module alu (alu_input_1, alu_input_2,
			opcode, func_code,
			
			alu_output, bcond);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
    input wire [3:0] opcode;
    input wire [5:0] func_code;

	output reg [`NumBits-1:0] alu_output;
	output reg bcond;

	wire [`NumBits - 1: 0] add_out;
	wire [`NumBits - 1: 0] sub_out;

	wire [`NumBits - 1: 0] not_out;
	wire [`NumBits - 1: 0] and_out;
	wire [`NumBits - 1: 0] orr_out;

	wire [`NumBits - 1: 0] tcp_out;
	wire [`NumBits - 1: 0] shl_out;
	wire [`NumBits - 1: 0] shr_out;



	ADDModule add_module (
		.A(alu_input_1), .B(alu_input_2), 
		.C(add_out)
	);
	SUBModule sub_module (
		.A(alu_input_1), .B(alu_input_2),
		.C(sub_out)
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
		alu_output = 0;
	end

	always @(alu_input_1 or alu_input_2 or opcode or func_code) begin
		case (opcode)
			`ALU_OP:begin
				case (func_code)
					`INST_FUNC_ADD:begin alu_output = add_out; end
					`INST_FUNC_SUB:begin alu_output = sub_out; end
					`INST_FUNC_AND:begin alu_output = and_out; end
					`INST_FUNC_ORR:begin alu_output = orr_out; end
					`INST_FUNC_NOT:begin alu_output = not_out; end
					`INST_FUNC_TCP:begin alu_output = tcp_out; end
					`INST_FUNC_SHL:begin alu_output = shl_out; end
					`INST_FUNC_SHR:begin alu_output = shr_out; end
					`INST_FUNC_JPR:begin alu_output = alu_input_1; end
					`INST_FUNC_JRL:begin alu_output = alu_input_1; end
					default:begin alu_output = 0; end
				endcase
			end

			`BNE_OP:begin alu_output = (alu_input_1 != alu_input_2); end
			`BEQ_OP:begin alu_output = (alu_input_1 == alu_input_2); end
			`BGZ_OP:begin alu_output = (alu_input_1 > 0); end
			`BLZ_OP:begin alu_output = (alu_input_1 < 0); end

			`ADI_OP:begin alu_output = add_out; end
			`ORI_OP:begin alu_output = orr_out; end
			`LHI_OP:begin alu_output = alu_input_2; end
			`LWD_OP:begin alu_output = add_out; end
			`SWD_OP:begin alu_output = add_out; end

			default:begin alu_output = 0; end
		endcase
	end


endmodule
