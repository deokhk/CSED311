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

wire [data_width - 1: 0] add_out;
wire add_flag;
wire [data_width - 1: 0] sub_out;
wire sub_flag;

wire [data_width - 1: 0] not_out;
wire [data_width - 1: 0] and_out;
wire [data_width - 1: 0] or_out;
wire [data_width - 1: 0] nand_out;
wire [data_width - 1: 0] nor_out;
wire [data_width - 1: 0] xor_out;
wire [data_width - 1: 0] xnor_out;

wire [data_width - 1: 0] lls_out;
wire [data_width - 1: 0] lrs_out;
wire [data_width - 1: 0] als_out;
wire [data_width - 1: 0] ars_out;

wire [data_width - 1: 0] id_out;
wire [data_width - 1: 0] tcp_out;
wire [data_width - 1: 0] zero_out;


ADDModule add_module (
	.A(A), .B(B), 
	.C(add_out), .OverflowFlag(add_flag)
);
SUBModule sub_module (
	.A(A), .B(B),
	.C(sub_out), .OverflowFlag(sub_flag)
);


NOTModule not_module (
	.A(A),
	.C(not_out)
);
ANDModule and_module (
	.A(A), .B(B),
	.C(and_out)
);
ORModule or_module (
	.A(A), .B(B),
	.C(or_out)
);
NANDModule nand_module (
	.A(A), .B(B),
	.C(nand_out)
);
NORModule nor_module (
	.A(A), .B(B),
	.C(nor_out)
);
XORModule xor_module (
	.A(A), .B(B),
	.C(xor_out)
);
XNORModule xnor_module (
	.A(A), .B(B),
	.C(xnor_out)
);


LLSModule lls_module (
	.A(A), 
	.C(lls_out)
);
LRSModule lrs_module (
	.A(A), 
	.C(lrs_out)
);
ALSModule als_module (
	.A(A), 
	.C(als_out)
);
ARSModule ars_module (
	.A(A), 
	.C(ars_out)
);


IDModule id_module (
	.A(A),
	.C(id_out)
);
TCPModule tcp_module (
	.A(A), 
	.C(tcp_out)
);
ZEROModule zero_module (
	.C(zero_out)
);


initial begin
	C = 0;
	OverflowFlag = 0;
end

always @(A or B or FuncCode) begin
    case (FuncCode)
		`FUNC_ADD:begin C<=add_out; OverflowFlag<=add_flag; end
		`FUNC_SUB:begin C<=sub_out; OverflowFlag<=sub_flag; end

		`FUNC_NOT:begin C<=not_out; OverflowFlag<=0; end
		`FUNC_AND:begin C<=and_out; OverflowFlag<=0; end
		`FUNC_OR:begin C<=or_out; OverflowFlag<=0; end
		`FUNC_NAND:begin C<=nand_out; OverflowFlag<=0; end
		`FUNC_NOR:begin C<=nor_out; OverflowFlag<=0; end
		`FUNC_XOR:begin C<=xor_out; OverflowFlag<=0; end
		`FUNC_XNOR:begin C<=xnor_out; OverflowFlag<=0; end

		`FUNC_LLS:begin C<=lls_out; OverflowFlag<=0; end
		`FUNC_LRS:begin C<=lrs_out; OverflowFlag<=0; end
		`FUNC_ALS:begin C<=als_out; OverflowFlag<=0; end
		`FUNC_ARS:begin C<=ars_out; OverflowFlag<=0; end

		`FUNC_ID:begin C<=id_out; OverflowFlag<=0; end
		`FUNC_TCP:begin C<=tcp_out; OverflowFlag<=0; end
		`FUNC_ZERO:begin C<=zero_out; OverflowFlag<=0; end
        default:begin C<=0; OverflowFlag<=0; end
    endcase
end

endmodule
