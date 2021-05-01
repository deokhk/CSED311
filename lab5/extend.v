`include "opcodes.v"


module ExtendDelegator(pc, opcode,
                        immediate_and_offset, target_address,
                        
                        extended_output);

    input wire [15:0] pc;
    input wire [3:0] opcode;
    input wire [7:0] immediate_and_offset;
    input wire [11:0] target_address;

    output wire [15:0] extended_output;

	wire [15:0] sign_extend_out;
	wire [15:0] msb_zero_extend_out;
	wire [15:0] lsb_zero_extend_out;
	wire [15:0] concat_pc_target_out;


	SignExtend8to16 sign_extend_8_to_16_instance (
		.in(immediate_and_offset), .out(sign_extend_out)
	);
	MsbZeroExtend8to16 msb_zero_extend_8_to_16_instance (
		.in(immediate_and_offset), .out(msb_zero_extend_out)
	);
	LsbZeroExtend8to16 lsb_zero_extend_8_to_16_instance (
		.in(immediate_and_offset), .out(lsb_zero_extend_out)
	);
	ConcatPc4Target12 concat_pc_4_target_12_instance (
		.pc(pc), .target(target_address), 
		.out(concat_pc_target_out)
	);

    assign extended_output = (opcode == `ADI_OP || opcode == `LWD_OP || opcode == `SWD_OP || 
                              opcode == `BNE_OP || opcode == `BEQ_OP || opcode == `BGZ_OP || 
                              opcode == `BLZ_OP) ? sign_extend_out :
                             (opcode == `ORI_OP ? msb_zero_extend_out : 
                             (opcode == `LHI_OP ? lsb_zero_extend_out : 
                             ((opcode == `JMP_OP || opcode == `JAL_OP) ? concat_pc_target_out : 0)));

endmodule


module SignExtend8to16(in, out);
    input wire [7:0] in;
    output wire [15:0] out;

    assign out = {{8{in[7]}}, in[7:0]};
endmodule


module MsbZeroExtend8to16(in, out);
    input wire [7:0] in;
    output wire [15:0] out;

    assign out = {8'b00000000,in[7:0]};

endmodule


module LsbZeroExtend8to16(in, out);
    input wire [7:0] in;
    output wire [15:0] out;

    assign out = {in[7:0],8'b00000000};

endmodule


module ConcatPc4Target12(pc, target, out);
    input wire [15:0] pc;
    input wire [11:0] target;
    output wire [15:0] out;

    assign out = {pc[15:12], target[11:0]};

endmodule
