`include "opcodes.v"
`include "alu.v" 	
`include "control_unit.v"
`include "extend.v"
`include "inst_decoder.v"
`include "mux.v"
`include "register_file.v"   

module cpu (data,

			ackOutput, inputReady,
			reset_n, clk,

			readM, writeM, address);
	inout [`WORD_SIZE-1:0] data;	

	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;

	output readM;									
	output writeM;
	output [`WORD_SIZE-1:0] address;	

	reg [`WORD_SIZE-1:0] pc;

	reg [`WORD_SIZE-1:0] one;

	wire [`WORD_SIZE-1:0] pc_plus_1;
	wire [`WORD_SIZE-1:0] pc_plus_imm;
	wire [`WORD_SIZE-1:0] pc_next;

	wire [`WORD_SIZE-1:0] extended_output;
	wire [`WORD_SIZE-1:0] alu_output;
	wire bcond;
	wire [1:0] pc_mux_sel;
	
    wire is_branch;
    wire is_jmp_jal;
    wire is_jpr_jrl;
    wire mem_read;
    wire mem_to_reg;
    wire mem_write;
    wire alu_src;
    wire reg_write;
    wire pc_to_reg;

	wire [3:0] opcode;
	wire [1:0] in_addr1;
	wire [1:0] in_addr2;
	wire [1:0] write_addr;
	wire [5:0] func_code;
	wire [7:0] immediate_and_offset;
	wire [11:0] target_address;

    wire [15:0] reg_data1;
    wire [15:0] reg_data2;
	wire [15:0] write_data;
	wire [15:0] mem_to_reg_data;
	wire [15:0] alu_src_data;


	initial begin
		// TODO
		pc;
		pc_plus_1;
		one = 1;
	end


	ADDModule pc_plus_1_adder (
		.A(pc), .B(one),
		.C(pc_plus_1)
	);
	ADDModule pc_plus_imm_adder (
		.A(pc), .B(extended_output),
		.C(pc_plus_imm)
	);


 	Mux4to1 pc_mux (
		.in0(pc_plus_1), .in1(pc_plus_imm),
		.in2(extended_output), .in3(alu_output), .sel(pc_mux_sel),

        .out(pc_next)
	);
	Mux2to1 pc_to_reg_mux(
		.in0(mem_to_reg_data), .in1(pc), .sel(pc_to_reg),
        .out(write_data)
	);
	Mux2to1 mem_to_reg_mux(
		.in0(alu_output), .in1(**************), .sel(mem_to_reg),
        .out(mem_to_reg_data)
	);
	Mux2to1 alu_src_mux(
		.in0(reg_data2), .in1(extended_output), .sel(alu_src),
        .out(alu_src_data)
	);
    PcMuxSelector pc_mux_selector (
		.is_branch(is_branch), .is_jmp_jal(is_jmp_jal),
		.is_jpr_jrl(is_jpr_jrl), .bcond(bcond),

        .pc_mux_sel(pc_mux_sel)
	);


	Control control (
		.opcode(opcode), .func_code(func_code),

		.is_branch(is_branch), .is_jmp_jal(is_jmp_jal), .is_jpr_jrl(is_jpr_jrl),
		.mem_read(mem_read), .mem_to_reg(mem_to_reg), .mem_write(mem_write),
		.alu_src(alu_src), .reg_write(reg_write), .pc_to_reg(pc_to_reg)
	);

    ALU alu (
		.alu_input_1(reg_data1), .alu_input_2(alu_src_data),
		.opcode(opcode), .func_code(func_code),
			
		.alu_output(alu_output), .bcond(bcond)
	);

	InstDecoder inst_decoder (
		.inst(*****************), 
                    
		.opcode(opcode), .in_addr1(in_addr1), .in_addr2(in_addr2),
		.write_addr(write_addr), .func_code(func_code),
		.immediate_and_offset(immediate_and_offset), .target_address(target_address)
	);

	RegisterFile register_file(
		.in_addr1(in_addr1), .in_addr2(in_addr2),
        .write_addr(write_addr), .write_data(write_data),
        .reg_write_signal(reg_write), .clk(clk),

        .reg_data1(reg_data1), .reg_data2(reg_data2)
	); 

	ExtendDelegator extend_delegator(
		.pc(pc), .opcode(opcode),
        .immediate_and_offset(immediate_and_offset), .target_address(target_address),
                        
        .extended_output(extended_output)
	);




	// combinational logic
	always @(*) begin
	// 컨트롤 모듈에서, SWD 면 -> writeM = 1
	// 끝나면 writeM  = 0
	// ackOutput == 0 이 되면, -> writeM  = 0
	// read 는 input ready 

	end



	// sequential logic 으로 pc, 다른 register 연산 수행
	always @(posedge clk) begin

		pc <= pc_next;

	end

endmodule							  																		  