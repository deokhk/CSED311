`include "module_add_sub.v"
`include "module_bitwise.v"
`include "module_shift.v"
`include "module_others.v"


module ALU #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
wire add_sub_out;
wire add_sub_flag;
wire bitwise_out;
wire bitwise_flag;
wire shift_out;
wire shift_flag;
wire others_out;
wire others_flag;

add_sub add_sub_component (
	.A(A), .B(B), .FuncCode(FuncCode),
	.C(add_sub_out), .OverflowFlag(add_sub_flag)
);

bitwise bitwise_component (
	.A(A), .B(B), .FuncCode(FuncCode),
	.C(bitwise_out), .OverflowFlag(bitwise_flag)
);

shift shift_component (
	.A(A), .B(B), .FuncCode(FuncCode),
	.C(shift_out), .OverflowFlag(shift_flag)
);

others others_component (
	.A(A), .B(B), .FuncCode(FuncCode),
	.C(others_out), .OverflowFlag(others_flag)
);

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/
always @(A or B or FuncCode) begin
    case (FuncCode)
		`FUNC_ADD:begin C<=add_sub_out; OverflowFlag<=add_sub_flag; end
		`FUNC_SUB:begin C<=add_sub_out; OverflowFlag<=add_sub_flag; end
		`FUNC_ID:begin C<=others_out; OverflowFlag<=others_flag; end
		`FUNC_NOT:begin C<=bitwise_out; OverflowFlag<=bitwise_flag; end
		`FUNC_AND:begin C<=bitwise_out; OverflowFlag<=bitwise_flag; end
		`FUNC_OR:begin C<=bitwise_out; OverflowFlag<=bitwise_flag; end
		`FUNC_NAND:begin C<=bitwise_out; OverflowFlag<=bitwise_flag; end
		`FUNC_NOR:begin C<=bitwise_out; OverflowFlag<=bitwise_flag; end
		`FUNC_XOR:begin C<=bitwise_out; OverflowFlag<=bitwise_flag; end
		`FUNC_XNOR:begin C<=bitwise_out; OverflowFlag<=bitwise_flag; end
		`FUNC_LLS:begin C<=shift_out; OverflowFlag<=shift_flag; end
		`FUNC_LRS:begin C<=shift_out; OverflowFlag<=shift_flag; end
		`FUNC_ALS:begin C<=shift_out; OverflowFlag<=shift_flag; end
		`FUNC_ARS:begin C<=shift_out; OverflowFlag<=shift_flag; end
		`FUNC_TCP:begin C<=others_out; OverflowFlag<=others_flag; end
		`FUNC_ZERO:begin C<=others_out; OverflowFlag<=others_flag; end
        default:begin C<=0; OverflowFlag<=0; end
    endcase
end

endmodule

