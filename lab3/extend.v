`include "opcodes.v"


module ExtendDelegator(pc, opcode,
                        immediate_and_offset, target_address,
                        
                        extended_output);

    input wire [15:0] pc;
    input wire [3:0] opcode;
    input wire [7:0] immediate_and_offset;
    input wire [11:0] target_address;

    output reg [15:0] extended_output;

	wire [15:0] sign_extend_out;
	wire [15:0] msb_zero_extend_out;
	wire [15:0] lsb_zero_extend_out;
	wire [15:0] concat_pc_target_out;


	sign_extend_8_to_16 sign_extend_8_to_16_instance (
		.in(immediate_and_offset), .out(sign_extend_out)
	);
	msb_zero_extend_8_to_16 msb_zero_extend_8_to_16_instance (
		.in(immediate_and_offset), .out(msb_zero_extend_out)
	);
	lsb_zero_extend_8_to_16 lsb_zero_extend_8_to_16_instance (
		.in(immediate_and_offset), .out(lsb_zero_extend_out)
	);
	concat_pc_4_target_12 concat_pc_4_target_12_instance (
		.pc(pc), .target(target_address), 
		.out(concat_pc_target_out)
	);


	initial begin
		extended_output = 0;
	end


    always @(*) begin
        case (opcode)
            `ADI_OP: extended_output = sign_extend_out;
            `LWD_OP: extended_output = sign_extend_out;
            `SWD_OP: extended_output = sign_extend_out;
            `BNE_OP: extended_output = sign_extend_out;
            `BEQ_OP: extended_output = sign_extend_out;
            `BGZ_OP: extended_output = sign_extend_out;
            `BLZ_OP: extended_output = sign_extend_out;

            `ORI_OP: extended_output = msb_zero_extend_out;

            `LHI_OP: extended_output = lsb_zero_extend_out;

            `JMP_OP: extended_output = sign_extend_out;
            `JAL_OP: extended_output = sign_extend_out;

            default : extended_output = 0;
        endcase
    end

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
