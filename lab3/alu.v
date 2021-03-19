`include "opcodes.v"
`include "alu_operations/module_add_sub.v"
`include "alu_operations/module_bitwise.v"
`include "alu_operations/module_others.v"


`define	NumBits	16


module alu (alu_input_1, alu_input_2, func_code, alu_output);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
	input [2:0] func_code;
	output reg [`NumBits-1:0] alu_output;

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

	always @(alu_input_1 or alu_input_2 or func_code) begin
		case (func_code)
			`FUNC_ADD:begin alu_output = add_out; end
			`FUNC_SUB:begin alu_output = sub_out; end

			`FUNC_AND:begin alu_output = and_out; end
			`FUNC_ORR:begin alu_output = orr_out; end
			`FUNC_NOT:begin alu_output = not_out; end

			`FUNC_TCP:begin alu_output = tcp_out; end
			`FUNC_SHL:begin alu_output = shl_out; end
			`FUNC_SHR:begin alu_output = shr_out; end

			default:begin alu_output = 0; end
		endcase
	end


endmodule
