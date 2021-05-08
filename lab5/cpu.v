`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "alu.v"
`include "control_unit.v"
`include "extend.v"
`include "forward.v"
`include "hazard.v"
`include "inst_parser.v"

`include "opcodes.v"
`include "register_file.v"
`include "util.v"


module cpu(clk, reset_n,
		   read_m1, address1, data1,
		   read_m2, write_m2, address2, data2, // inout
		   num_inst, output_port, is_halted,

		   is_stall, opcode_ip, opcode_out_cu,
		   opcode_ex, opcode_mem, opcode_wb,

		   forward_a_out, forward_a,
		   alu_src_mux_out, alu_result_alu,
		   mem_data_wb, mem_to_reg_out, reg_write_wb,

		   j_or_b_pc_candidate_mem, bcond_mem

);

	input clk;
	input reset_n;

	// read_m1, address1, data1: instruction memory
	// read_m2, write_m2, address2, data2: data memory
	input [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;

	output read_m1;
	output [`WORD_SIZE-1:0] address1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] address2;

	output reg [`WORD_SIZE-1:0] num_inst;
	output reg [`WORD_SIZE-1:0] output_port;
	output is_halted;


	wire [`WORD_SIZE-1:0] pc_plus_1;
	wire [`WORD_SIZE-1:0] pc_next;

	wire [`WORD_SIZE-1:0] pc_id;
	wire [`WORD_SIZE-1:0] inst_id;

    output wire [3:0] opcode_ip;
    wire [1:0] in_addr1_ip;
    wire [1:0] in_addr2_ip;
    wire [1:0] write_addr_ip;
    wire [5:0] func_code_ip;
    wire [7:0] immediate_and_offset_ip;
    wire [11:0] target_address_ip;

	output wire [3:0] opcode_out_cu;
	wire [5:0] func_code_out_cu;
	wire is_branch_cu;
	wire is_jmp_jal_cu;
	wire is_jpr_jrl_cu;
	wire mem_read_cu;
	wire mem_to_reg_cu;
	wire mem_write_cu;
	wire alu_src_cu;
	wire reg_write_cu;
	wire pc_to_reg_cu;

    wire [15:0] extended_output_ed;

	wire [`WORD_SIZE-1:0] pc_wb_plus_1_out;

	wire [15:0] wb_mux_out;
	wire [`WORD_SIZE-1:0] reg_data1_rf;
	wire [`WORD_SIZE-1:0] reg_data2_rf;
	wire [15:0] registers_rf [3:0]; // For debugging purpose

	output wire [3:0] opcode_ex;
	wire [5:0] func_code_ex;
	wire [`WORD_SIZE-1:0] pc_ex;
	wire [1:0] in_addr1_ex;
	wire [1:0] in_addr2_ex;
	wire [`WORD_SIZE-1:0] reg_data1_ex;
	wire [`WORD_SIZE-1:0] reg_data2_ex;
	wire [`WORD_SIZE-1:0] extended_output_ex;
	wire [1:0] rd_addr_ex;
	wire is_branch_ex;
	wire is_jmp_jal_ex;
	wire is_jpr_jrl_ex;
	wire mem_read_ex;
	wire mem_to_reg_ex;
	wire mem_write_ex;
	wire alu_src_ex;
	wire reg_write_ex;
	wire pc_to_reg_ex;

	output wire is_stall;

    output wire [1:0] forward_a;
    wire [1:0] forward_b;

	wire [`WORD_SIZE-1:0] pc_mem_plus_1_out;
	wire is_jal_jrl_mem;
	wire is_jal_jrl_wb;
	wire [`WORD_SIZE-1:0] dist1_forward_out;
	wire [`WORD_SIZE-1:0] dist2_forward_out;

	output wire [`WORD_SIZE-1:0] forward_a_out;
	wire [`WORD_SIZE-1:0] forward_b_out;
	output wire [`WORD_SIZE-1:0] alu_src_mux_out;

	output wire [`WORD_SIZE-1:0] alu_result_alu;
	wire bcond_alu;

	wire [1:0] pc_mux_sel;

	wire [`WORD_SIZE-1:0] extended_output_plus_1;
	wire [`WORD_SIZE-1:0] pc_plus_offset;
	wire [`WORD_SIZE-1:0] j_or_b_pc_mux_out;

	output wire [3:0] opcode_mem;
	wire [5:0] func_code_mem;
	wire [`WORD_SIZE-1:0] pc_mem;
	output wire [`WORD_SIZE-1:0] j_or_b_pc_candidate_mem;
	output wire bcond_mem;
	wire [`WORD_SIZE-1:0] alu_result_mem;
	wire [`WORD_SIZE-1:0] forwarded_data1_mem;
	wire [`WORD_SIZE-1:0] forwarded_data2_mem;
	wire [1:0] rd_addr_mem;

	wire is_branch_mem;
	wire is_jmp_jal_mem;
	wire is_jpr_jrl_mem;
	wire mem_read_mem;
	wire mem_to_reg_mem;
	wire mem_write_mem;
	wire reg_write_mem;
	wire pc_to_reg_mem;

	wire no_flush_condition;
 	wire control_hazard_flush;

	wire is_j_or_b_taken;

	output wire [3:0] opcode_wb;
	wire [5:0] func_code_wb;
	wire [`WORD_SIZE-1:0] pc_wb;
	wire [`WORD_SIZE-1:0] alu_result_wb;
	output wire [`WORD_SIZE-1:0] mem_data_wb;
	wire [`WORD_SIZE-1:0] forwarded_data1_wb;
	wire [1:0] rd_addr_wb;
	wire mem_to_reg_wb;
	output wire reg_write_wb;
	wire pc_to_reg_wb;

	output wire [`WORD_SIZE-1:0] mem_to_reg_out;


	reg [`WORD_SIZE-1:0] pc;
	reg [`WORD_SIZE-1:0] one;

	// NOTE: is_branch_mem && bcond_mem 이거가 이미 j_or_b_taken 인데?
	assign no_flush_condition = ((pc_mem + 1) == j_or_b_pc_candidate_mem);
	// no_flush_condition: 1 -> no flush
	// no_flush_condition: 0 -> flush

	assign control_hazard_flush = (is_j_or_b_taken && (!no_flush_condition)); // j_or_b_pc_candidate_mem
	// opcode == Jxx && ((pc_mem + 1) == j_or_b_pc_candidate_mem)  -> No flush !!!!
	// opcode == Bxx && ((pc_mem + 1) == j_or_b_pc_candidate_mem) && bcond_mem -> No flush !!!

	assign read_m1 = reset_n;
	assign address1 = pc;

	assign read_m2 = mem_read_mem;
	assign write_m2 = mem_write_mem;
	assign address2 = alu_result_mem;
	assign data2 = write_m2 ? forwarded_data2_mem : `WORD_SIZE'bz;

	assign is_halted = ((opcode_wb == `HLT_OP) && (func_code_wb == `INST_FUNC_HLT));

	assign is_jal_jrl_mem = (opcode_mem == `JAL_OP) || ((opcode_mem == `JRL_OP) && (func_code_mem == `INST_FUNC_JRL));
	assign is_jal_jrl_wb = (opcode_wb == `JAL_OP) || ((opcode_wb == `JRL_OP) && (func_code_wb == `INST_FUNC_JRL));


	ADDModule pc_plus_1_adder (
		.A(pc), .B(one),
		.C(pc_plus_1)
	);
	Mux2to1 pc_mux (
		.in0(pc_plus_1), .in1(j_or_b_pc_candidate_mem), .sel(control_hazard_flush),
		.out(pc_next)
	);


	IFIDPipeline IF_ID_pipeline (
		.clk(clk), .reset_n(reset_n),
		.new_pc(pc), .new_inst(data1),
		.data_hazard_stall(is_stall), .control_hazard_flush(control_hazard_flush),

		.pc_id(pc_id), .inst_id(inst_id)
	);

	InstParser inst_parser (
		.inst(inst_id),

		.opcode(opcode_ip), .in_addr1(in_addr1_ip), .in_addr2(in_addr2_ip),
		.write_addr(write_addr_ip), .func_code(func_code_ip),
		.immediate_and_offset(immediate_and_offset_ip), .target_address(target_address_ip)
	);

	ControlUnit control_unit (
		.opcode(opcode_ip), .func_code(func_code_ip),

		.opcode_out(opcode_out_cu), .func_code_out(func_code_out_cu),
		.is_branch(is_branch_cu), .is_jmp_jal(is_jmp_jal_cu), .is_jpr_jrl(is_jpr_jrl_cu),
		.mem_read(mem_read_cu), .mem_to_reg(mem_to_reg_cu), .mem_write(mem_write_cu),
		.alu_src(alu_src_cu), .reg_write(reg_write_cu), .pc_to_reg(pc_to_reg_cu)
	);

	ExtendDelegator extend_delegator (
		.pc(pc_id), .opcode(opcode_ip),
		.immediate_and_offset(immediate_and_offset_ip), .target_address(target_address_ip),

		.extended_output(extended_output_ed)
	);

	ADDModule pc_wb_plus_1 (
		.A(pc_wb), .B(one),
		.C(pc_wb_plus_1_out)
	);

	Mux2to1 wb_mux (
		.in0(mem_to_reg_out), .in1(pc_wb_plus_1_out), .sel(pc_to_reg_wb),
		.out(wb_mux_out)
	);

	// TODO: 일단 한 번 다 연결하고, 돌리기 전에 시나리오대로 연결되어있는지 확인.
	RegisterFile register_file (
		.clk(clk), .reset_n(reset_n),
		.in_addr1(in_addr1_ip), .in_addr2(in_addr2_ip), // younger
		.write_addr(rd_addr_wb), // older // TODO: LWD 일 때는 rt_addr_wb 이 들어가야 하는 거 아님?
		.write_data(wb_mux_out), // older
		.reg_write_signal(reg_write_wb), // older

		.reg_data1(reg_data1_rf), .reg_data2(reg_data2_rf), .registers(registers_rf)
	);

	IDEXPipeline ID_EX_pipeline (
		.clk(clk), .reset_n(reset_n),
		.new_opcode(opcode_out_cu), .new_func_code(func_code_out_cu),
		.new_pc(pc_id), .new_in_addr1(in_addr1_ip), .new_in_addr2(in_addr2_ip),
		.new_reg_data1(reg_data1_rf), .new_reg_data2(reg_data2_rf),
		.new_extended_output(extended_output_ed), .new_rd_addr(write_addr_ip),
		.new_is_branch(is_branch_cu), .new_is_jmp_jal(is_jmp_jal_cu), .new_is_jpr_jrl(is_jpr_jrl_cu),
		.new_mem_read(mem_read_cu), .new_mem_to_reg(mem_to_reg_cu), .new_mem_write(mem_write_cu),
		.new_alu_src(alu_src_cu), .new_reg_write(reg_write_cu), .new_pc_to_reg(pc_to_reg_cu),
		.data_hazard_stall(is_stall), .control_hazard_flush(control_hazard_flush),

		.opcode_ex(opcode_ex), .func_code_ex(func_code_ex),
		.pc_ex(pc_ex), .in_addr1_ex(in_addr1_ex), .in_addr2_ex(in_addr2_ex),
		.reg_data1_ex(reg_data1_ex), .reg_data2_ex(reg_data2_ex),
		.extended_output_ex(extended_output_ex), .rd_addr_ex(rd_addr_ex),
		.is_branch_ex(is_branch_ex), .is_jmp_jal_ex(is_jmp_jal_ex), .is_jpr_jrl_ex(is_jpr_jrl_ex),
		.mem_read_ex(mem_read_ex), .mem_to_reg_ex(mem_to_reg_ex), .mem_write_ex(mem_write_ex),
		.alu_src_ex(alu_src_ex), .reg_write_ex(reg_write_ex), .pc_to_reg_ex(pc_to_reg_ex)
    );

	HazardDetection hazard_detection (
		.rs1_addr_id(in_addr1_ip), .rs2_addr_id(in_addr2_ip),
		.opcode_id(opcode_ip), .func_code_id(func_code_ip),
		.rd_addr_ex(rd_addr_ex), .mem_read_ex(mem_read_ex),

		.is_stall(is_stall)
	);

	ForwardingUnit forwarding_unit (
		.rs1_addr_ex(in_addr1_ex), .rs2_addr_ex(in_addr2_ex),
		.rd_addr_mem(rd_addr_mem), .reg_write_mem(reg_write_mem),
		.rd_addr_wb(rd_addr_wb), .reg_write_wb(reg_write_wb),
		
		.forward_a(forward_a), .forward_b(forward_b)
	);

	// register 에 wb 될 애들을 써야 함.
	// in1 부터
	// ADI, ORI, LHI: alu_result_mem
	// LWD: 고려안해도 됨! 어차피 stall
	// ALU_OP except JRL: alu_result_mem
	// JAL, JRL: !!! $2 = PC + 1.

	// TODO: dist 2 에서 오는 건, mem_to_reg mux 의 output 임
	// in2
	// ADI, ORI, LHI: alu_result_wb
	// LWD: mem_data_wb
	// ALU_OP except JRL: alu_result_wb
	// JAL, JRL: !!! $2 = PC + 1.

	ADDModule pc_mem_plus_1 (
		.A(pc_mem), .B(one),
		.C(pc_mem_plus_1_out)
	);


	Mux2to1 dist1_forward_mux (
		.in0(alu_result_mem), .in1(pc_mem_plus_1_out), .sel(is_jal_jrl_mem),
		.out(dist1_forward_out)
	);
	Mux2to1 dist2_forward_mux (
		// TODO: in0 이거 mem_reg_out 아님?
		.in0(mem_to_reg_out), .in1(pc_wb_plus_1_out), .sel(is_jal_jrl_wb),
		.out(dist2_forward_out)
	);


	Mux3to1 forward_a_mux (
		.in0(reg_data1_ex), .in1(dist1_forward_out), .in2(dist2_forward_out), .sel(forward_a),
    	.out(forward_a_out)
	);

	Mux3to1 forward_b_mux (
		.in0(reg_data2_ex), .in1(dist1_forward_out), .in2(dist2_forward_out), .sel(forward_b),
        .out(forward_b_out)
	);

	Mux2to1 alu_src_mux (
		.in0(forward_b_out), .in1(extended_output_ex), .sel(alu_src_ex),
        .out(alu_src_mux_out)
	);

	ALU alu (
		.alu_input_1(forward_a_out), .alu_input_2(alu_src_mux_out),
		.opcode(opcode_ex), .func_code(func_code_ex),

        .alu_result(alu_result_alu), .bcond(bcond_alu)
	);

	PcMuxSelector pc_mux_selector (
		.is_branch(is_branch_ex), .is_jmp_jal(is_jmp_jal_ex), .is_jpr_jrl(is_jpr_jrl_ex), .bcond(bcond_alu),
					
		.pc_mux_sel(pc_mux_sel)
	);

	ADDModule extended_output_plus_one_adder (
		.A(extended_output_ex), .B(one),
		.C(extended_output_plus_1)
	);

	ADDModule pc_plus_offset_adder (
		.A(pc_ex), .B(extended_output_plus_1),
		.C(pc_plus_offset)
	);

	Mux3to1 j_or_b_pc_mux (
		.in0(pc_plus_offset), .in1(extended_output_ex), .in2(forward_a_out), .sel(pc_mux_sel),
        .out(j_or_b_pc_mux_out)
	);


// PC MUX
// 0: Bxx. pc + offset + 1 (with distinct Adder)
// 1: JMP, JAL: extended_output_ex 그대로.
// 2: JPR, JRL: rs 그대로


	EXMEMPipeline EX_MEM_pipeline (
		.clk(clk), .reset_n(reset_n),
		.new_opcode(opcode_ex), .new_func_code(func_code_ex),
		.new_pc(pc_ex), 
		.new_j_or_b_pc_candidate(j_or_b_pc_mux_out), 
		.new_bcond(bcond_alu), .new_alu_result(alu_result_alu),
		.new_forwarded_data1(forward_a_out), .new_forwarded_data2(forward_b_out), .new_rd_addr(rd_addr_ex),
		.new_is_branch(is_branch_ex), .new_is_jmp_jal(is_jmp_jal_ex), .new_is_jpr_jrl(is_jpr_jrl_ex),
		.new_mem_read(mem_read_ex), .new_mem_to_reg(mem_to_reg_ex),
		.new_mem_write(mem_write_ex), .new_reg_write(reg_write_ex), .new_pc_to_reg(pc_to_reg_ex),
		.control_hazard_flush(control_hazard_flush),

		.opcode_mem(opcode_mem), .func_code_mem(func_code_mem),
		.pc_mem(pc_mem),
		.j_or_b_pc_candidate_mem(j_or_b_pc_candidate_mem),
		.bcond_mem(bcond_mem), .alu_result_mem(alu_result_mem),
		.forwarded_data1_mem(forwarded_data1_mem), .forwarded_data2_mem(forwarded_data2_mem), .rd_addr_mem(rd_addr_mem),
		.is_branch_mem(is_branch_mem), .is_jmp_jal_mem(is_jmp_jal_mem), .is_jpr_jrl_mem(is_jpr_jrl_mem),
		.mem_read_mem(mem_read_mem), .mem_to_reg_mem(mem_to_reg_mem), .mem_write_mem(mem_write_mem),
		.reg_write_mem(reg_write_mem), .pc_to_reg_mem(pc_to_reg_mem)
	);

	JorBTakenUnit j_or_b_taken_unit (
		.is_branch(is_branch_mem), .is_jmp_jal(is_jmp_jal_mem),
		.is_jpr_jrl(is_jpr_jrl_mem), .bcond(bcond_mem),

        .is_j_or_b_taken(is_j_or_b_taken)
	);

	MEMWBPipeline MEM_WB_pipeline (
		.clk(clk), .reset_n(reset_n),
		.new_opcode(opcode_mem), .new_func_code(func_code_mem),
		.new_pc(pc_mem), .new_alu_result(alu_result_mem), .new_mem_data(data2),
		.new_forwarded_data1(forwarded_data1_mem), .new_rd_addr(rd_addr_mem),
		.new_mem_to_reg(mem_to_reg_mem), .new_reg_write(reg_write_mem), .new_pc_to_reg(pc_to_reg_mem),
		
		.opcode_wb(opcode_wb), .func_code_wb(func_code_wb),
		.pc_wb(pc_wb), .alu_result_wb(alu_result_wb), .mem_data_wb(mem_data_wb),
		.forwarded_data1_wb(forwarded_data1_wb), .rd_addr_wb(rd_addr_wb),
		.mem_to_reg_wb(mem_to_reg_wb), .reg_write_wb(reg_write_wb), .pc_to_reg_wb(pc_to_reg_wb)
	);

	Mux2to1 mem_to_reg_mux (
		.in0(alu_result_wb), .in1(mem_data_wb), .sel(mem_to_reg_wb),
		.out(mem_to_reg_out)
	);


	initial begin
		pc = 0;
		one = 1;

		output_port = 0;
		num_inst = 0;

	end


	always @(posedge reset_n) begin
		pc <= 0;
		one <= 1;

		output_port <= 0;
		num_inst <= 0;
	end

	always @(posedge clk) begin
		if ((opcode_wb == `WWD_OP) && (func_code_wb == `INST_FUNC_WWD)) begin
			output_port <= forwarded_data1_wb;
		end

		if (opcode_wb != 0) begin
			num_inst <= (num_inst + 1);
		end

		if (is_stall == 0) begin
			pc <= pc_next;
		end

	end

endmodule


module IFIDPipeline(clk, reset_n, 
				    new_pc, new_inst,
					data_hazard_stall, control_hazard_flush,
					
					pc_id, inst_id);
				
	input wire clk;
	input wire reset_n;

	input wire [`WORD_SIZE-1:0] new_pc;
	input wire [`WORD_SIZE-1:0] new_inst;
	input wire data_hazard_stall;
	input wire control_hazard_flush;

	output wire [`WORD_SIZE-1:0] pc_id;
	output wire [`WORD_SIZE-1:0] inst_id;

	reg [`WORD_SIZE-1:0] pc;
	reg [`WORD_SIZE-1:0] inst;

	assign pc_id = pc;
	assign inst_id = inst;

	initial begin
		pc = 0;
		inst = 0;
	end

	always @(posedge reset_n) begin
		pc <= 0;
		inst <= 0;
	end

	always @(posedge clk) begin
		if (control_hazard_flush) begin
			pc <= 0;
			inst <= 0;
		end
		else if (!data_hazard_stall) begin // no control hazard, no data hazard
			pc <= new_pc;
			inst <= new_inst;
		end
		// NOTE: else == no control hazard, yes data hazard
	end
endmodule


module IDEXPipeline(clk, reset_n,
					new_opcode, new_func_code,
					new_pc, new_in_addr1, new_in_addr2,
					new_reg_data1, new_reg_data2,
					new_extended_output, new_rd_addr,
					new_is_branch, new_is_jmp_jal, new_is_jpr_jrl,
					new_mem_read, new_mem_to_reg, new_mem_write,
					new_alu_src, new_reg_write, new_pc_to_reg,
					data_hazard_stall, control_hazard_flush,

					opcode_ex, func_code_ex,
					pc_ex, in_addr1_ex, in_addr2_ex,
					reg_data1_ex, reg_data2_ex,
					extended_output_ex, rd_addr_ex,
					is_branch_ex, is_jmp_jal_ex, is_jpr_jrl_ex,
					mem_read_ex, mem_to_reg_ex, mem_write_ex,
					alu_src_ex, reg_write_ex, pc_to_reg_ex
					);
	input wire clk;
	input wire reset_n;
	
	input wire [3:0] new_opcode;
	input wire [5:0] new_func_code;
	input wire [`WORD_SIZE-1:0] new_pc;
	input wire [1:0] new_in_addr1;
	input wire [1:0] new_in_addr2;
	input wire [`WORD_SIZE-1:0] new_reg_data1;
	input wire [`WORD_SIZE-1:0] new_reg_data2;
	input wire [`WORD_SIZE-1:0] new_extended_output;
	input wire [1:0] new_rd_addr;

	input wire new_is_branch;
	input wire new_is_jmp_jal;
	input wire new_is_jpr_jrl;
	input wire new_mem_read;
	input wire new_mem_to_reg;
	input wire new_mem_write;
	input wire new_alu_src;
	input wire new_reg_write;
	input wire new_pc_to_reg;
	input wire data_hazard_stall;
	input wire control_hazard_flush;


	output wire [3:0] opcode_ex;
	output wire [5:0] func_code_ex;
	output wire [`WORD_SIZE-1:0] pc_ex;
	output wire [1:0] in_addr1_ex;
	output wire [1:0] in_addr2_ex;
	output wire [`WORD_SIZE-1:0] reg_data1_ex;
	output wire [`WORD_SIZE-1:0] reg_data2_ex;
	output wire [`WORD_SIZE-1:0] extended_output_ex;
	output wire [1:0] rd_addr_ex;

	output wire is_branch_ex;
	output wire is_jmp_jal_ex;
	output wire is_jpr_jrl_ex;
	output wire mem_read_ex;
	output wire mem_to_reg_ex;
	output wire mem_write_ex;
	output wire alu_src_ex;
	output wire reg_write_ex;
	output wire pc_to_reg_ex;


	reg [3:0] opcode;
	reg [5:0] func_code;
	reg [`WORD_SIZE-1:0] pc;
	reg [1:0] in_addr1;
	reg [1:0] in_addr2;
	reg [`WORD_SIZE-1:0] reg_data1;
	reg [`WORD_SIZE-1:0] reg_data2;
	reg [`WORD_SIZE-1:0] extended_output;
	reg [1:0] rd_addr;
	reg is_branch;
	reg is_jmp_jal;
	reg is_jpr_jrl;
	reg mem_read;
	reg mem_to_reg;
	reg mem_write;
	reg alu_src;
	reg reg_write;
	reg pc_to_reg;


	assign opcode_ex = opcode;
	assign func_code_ex = func_code;
	assign pc_ex = pc;
	assign in_addr1_ex = in_addr1;
	assign in_addr2_ex = in_addr2;
	assign reg_data1_ex = reg_data1;
	assign reg_data2_ex = reg_data2;
	assign extended_output_ex = extended_output;
	assign rd_addr_ex = rd_addr;
	assign is_branch_ex = is_branch;
	assign is_jmp_jal_ex = is_jmp_jal;
	assign is_jpr_jrl_ex = is_jpr_jrl;
	assign mem_read_ex = mem_read;
	assign mem_to_reg_ex = mem_to_reg;
	assign mem_write_ex = mem_write;
	assign alu_src_ex = alu_src;
	assign reg_write_ex = reg_write;
	assign pc_to_reg_ex = pc_to_reg;


	initial begin
		opcode = 0;
		func_code = 0;
		pc = 0;
		in_addr1 = 0;
		in_addr2 = 0;
		reg_data1 = 0;
		reg_data2 = 0;
		extended_output = 0;
		rd_addr = 0;

		is_branch = 0;
		is_jmp_jal = 0;
		is_jpr_jrl = 0;
		mem_read = 0;
		mem_to_reg = 0;
		mem_write = 0;
		alu_src = 0;
		reg_write = 0;
		pc_to_reg = 0;
	end


	always @(posedge reset_n) begin
		opcode <= 0;
		func_code <= 0;
		pc <= 0;
		in_addr1 <= 0;
		in_addr2 <= 0;
		reg_data1 <= 0;
		reg_data2 <= 0;
		extended_output <= 0;
		rd_addr <= 0;

		is_branch <= 0;
		is_jmp_jal <= 0;
		is_jpr_jrl <= 0;
		mem_read <= 0;
		mem_to_reg <= 0;
		mem_write <= 0;
		alu_src <= 0;
		reg_write <= 0;
		pc_to_reg <= 0;
	end

	always @(posedge clk) begin
		if (control_hazard_flush || data_hazard_stall) begin
			opcode <= 0;
			func_code <= 0;

			is_branch <= 0;
			is_jmp_jal <= 0;
			is_jpr_jrl <= 0;
			mem_read <= 0;
			mem_to_reg <= 0;
			mem_write <= 0;
			alu_src <= 0;
			reg_write <= 0;
			pc_to_reg <= 0;
		end
		else begin // no control hazard, no data hazard
			opcode <= new_opcode;
			func_code <= new_func_code;
			pc <= new_pc;
			in_addr1 <= new_in_addr1;
			in_addr2 <= new_in_addr2;
			reg_data1 <= new_reg_data1;
			reg_data2 <= new_reg_data2;
			extended_output <= new_extended_output;
			rd_addr <= new_rd_addr;

			is_branch <= new_is_branch;
			is_jmp_jal <= new_is_jmp_jal;
			is_jpr_jrl <= new_is_jpr_jrl;
			mem_read <= new_mem_read;
			mem_to_reg <= new_mem_to_reg;
			mem_write <= new_mem_write;
			alu_src <= new_alu_src;
			reg_write <= new_reg_write;
			pc_to_reg <= new_pc_to_reg;
		end
	end

endmodule


module EXMEMPipeline(clk, reset_n,
					 new_opcode, new_func_code,
					 new_pc, // 원래대로 proceed 하는 original pc
					 new_j_or_b_pc_candidate, // j_or_b_pc_mux 에서 나오는 output
					 new_bcond, new_alu_result,
					 new_forwarded_data1, new_forwarded_data2, new_rd_addr,
					 new_is_branch, new_is_jmp_jal, new_is_jpr_jrl,
					 new_mem_read, new_mem_to_reg,
					 new_mem_write, new_reg_write, new_pc_to_reg,
					 control_hazard_flush,
					 
					 opcode_mem, func_code_mem,
					 pc_mem,
 					 j_or_b_pc_candidate_mem,
					 bcond_mem, alu_result_mem,
					 forwarded_data1_mem, forwarded_data2_mem, rd_addr_mem,
					 is_branch_mem, is_jmp_jal_mem, is_jpr_jrl_mem,
					 mem_read_mem, mem_to_reg_mem, mem_write_mem,
					 reg_write_mem, pc_to_reg_mem);

	
	input wire clk;
	input wire reset_n;
	input wire [3:0] new_opcode;
	input wire [5:0] new_func_code;
	input wire [`WORD_SIZE-1:0] new_pc;
	input wire [`WORD_SIZE-1:0] new_j_or_b_pc_candidate;
	input wire new_bcond;
	input wire [`WORD_SIZE-1:0] new_alu_result;
	input wire [`WORD_SIZE-1:0] new_forwarded_data1;
	input wire [`WORD_SIZE-1:0] new_forwarded_data2;
	input wire [1:0] new_rd_addr;

	input wire new_is_branch;
	input wire new_is_jmp_jal;
	input wire new_is_jpr_jrl;
	input wire new_mem_read;
	input wire new_mem_to_reg;
	input wire new_mem_write;
	input wire new_reg_write;
	input wire new_pc_to_reg;
	input wire control_hazard_flush;


	output wire [3:0] opcode_mem;
	output wire [5:0] func_code_mem;
	output wire [`WORD_SIZE-1:0] pc_mem;
	output wire [`WORD_SIZE-1:0] j_or_b_pc_candidate_mem;
	output wire bcond_mem;
	output wire [`WORD_SIZE-1:0] alu_result_mem;
	output wire [`WORD_SIZE-1:0] forwarded_data1_mem;
	output wire [`WORD_SIZE-1:0] forwarded_data2_mem;
	output wire [1:0] rd_addr_mem;

	output wire is_branch_mem;
	output wire is_jmp_jal_mem;
	output wire is_jpr_jrl_mem;
	output wire mem_read_mem;
	output wire mem_to_reg_mem;
	output wire mem_write_mem;
	output wire reg_write_mem;
	output wire pc_to_reg_mem;

	reg [3:0] opcode;
	reg [5:0] func_code;
	reg [`WORD_SIZE-1:0] pc;
	reg [`WORD_SIZE-1:0] j_or_b_pc_candidate;
	reg bcond;
	reg [`WORD_SIZE-1:0] alu_result;
	reg [`WORD_SIZE-1:0] forwarded_data1;
	reg [`WORD_SIZE-1:0] forwarded_data2;
	reg [1:0] rd_addr;
	reg is_branch;
	reg is_jmp_jal;
	reg is_jpr_jrl;
	reg mem_read;
	reg mem_to_reg;
	reg mem_write;
	reg reg_write;
	reg pc_to_reg;

	assign opcode_mem = opcode;
	assign func_code_mem = func_code;
	assign pc_mem = pc;
	assign j_or_b_pc_candidate_mem = j_or_b_pc_candidate;
	assign bcond_mem = bcond;
	assign alu_result_mem = alu_result;
	assign forwarded_data1_mem = forwarded_data1;
	assign forwarded_data2_mem = forwarded_data2;
	assign rd_addr_mem = rd_addr;
	assign is_branch_mem = is_branch;
	assign is_jmp_jal_mem = is_jmp_jal;
	assign is_jpr_jrl_mem = is_jpr_jrl;
	assign mem_read_mem = mem_read;
	assign mem_to_reg_mem = mem_to_reg;
	assign mem_write_mem = mem_write;
	assign reg_write_mem = reg_write;
	assign pc_to_reg_mem = pc_to_reg;


	initial begin
		opcode = 0;
		func_code = 0;
		pc = 0;
		j_or_b_pc_candidate = 0;
		bcond = 0;
		alu_result = 0;
		forwarded_data1 = 0;
		forwarded_data2 = 0;
		rd_addr = 0;

		is_branch = 0;
		is_jmp_jal = 0;
		is_jpr_jrl = 0;
		mem_read = 0;
		mem_to_reg = 0;
		mem_write = 0;
		reg_write = 0;
		pc_to_reg = 0;
	end


	always @(posedge reset_n) begin
		opcode <= 0;
		func_code <= 0;
		pc <= 0;
		j_or_b_pc_candidate <= 0;
		bcond <= 0;
		alu_result <= 0;
		forwarded_data1 <= 0;
		forwarded_data2 <= 0;
		rd_addr <= 0;

		is_branch <= 0;
		is_jmp_jal <= 0;
		is_jpr_jrl <= 0;
		mem_read <= 0;
		mem_to_reg <= 0;
		mem_write <= 0;
		reg_write <= 0;
		pc_to_reg <= 0;
	end

	always @(posedge clk) begin
		if (control_hazard_flush) begin
			opcode <= 0;
			func_code <= 0;

			is_branch <= 0;
			is_jmp_jal <= 0;
			is_jpr_jrl <= 0;
			mem_read <= 0;
			mem_to_reg <= 0;
			mem_write <= 0;
			reg_write <= 0;
			pc_to_reg <= 0;
		end
		else begin // no control hazard, no data hazard
			opcode <= new_opcode;
			func_code <= new_func_code;
			pc <= new_pc;
			j_or_b_pc_candidate <= new_j_or_b_pc_candidate;
			bcond <= new_bcond;
			alu_result <= new_alu_result;
			forwarded_data1 <= new_forwarded_data1;
			forwarded_data2 <= new_forwarded_data2;
			rd_addr <= new_rd_addr;

			is_branch <= new_is_branch;
			is_jmp_jal <= new_is_jmp_jal;
			is_jpr_jrl <= new_is_jpr_jrl;
			mem_read <= new_mem_read;
			mem_to_reg <= new_mem_to_reg;
			mem_write <= new_mem_write;
			reg_write <= new_reg_write;
			pc_to_reg <= new_pc_to_reg;
		end
	end

endmodule


module MEMWBPipeline(clk, reset_n,
					 new_opcode, new_func_code,
					 new_pc, new_alu_result, new_mem_data,
					 new_forwarded_data1, new_rd_addr, 
					 new_mem_to_reg, new_reg_write, new_pc_to_reg,
					 
					 opcode_wb, func_code_wb,// CPU에서 해당 값을 봐서 0이면 non-valid한 instruction이라 num_inst를 1 증가시켜주지 않고, 그 이외의 경우 num_inst 1증가.
					 pc_wb, alu_result_wb, mem_data_wb,
					 forwarded_data1_wb, rd_addr_wb,
					 mem_to_reg_wb, reg_write_wb, pc_to_reg_wb
);
	input wire clk;
	input wire reset_n;
	input wire [3:0] new_opcode;
	input wire [5:0] new_func_code;
	input wire [`WORD_SIZE-1:0] new_pc;
	input wire [`WORD_SIZE-1:0] new_alu_result;
	input wire [`WORD_SIZE-1:0] new_mem_data;
	input wire [`WORD_SIZE-1:0] new_forwarded_data1;
	input wire [1:0] new_rd_addr;
	input wire new_mem_to_reg;
	input wire new_reg_write;
	input wire new_pc_to_reg;


	output wire [3:0] opcode_wb;
	output wire [5:0] func_code_wb;
	output wire [`WORD_SIZE-1:0] pc_wb;
	output wire [`WORD_SIZE-1:0] alu_result_wb;
	output wire [`WORD_SIZE-1:0] mem_data_wb;
	output wire [`WORD_SIZE-1:0] forwarded_data1_wb;
	output wire [1:0] rd_addr_wb;
	output wire mem_to_reg_wb;
	output wire reg_write_wb;
	output wire pc_to_reg_wb;


	reg [3:0] opcode;
	reg [5:0] func_code;
	reg [`WORD_SIZE-1:0] pc;
	reg [`WORD_SIZE-1:0] alu_result;
	reg [`WORD_SIZE-1:0] mem_data;
	reg [`WORD_SIZE-1:0] forwarded_data1;
	reg [1:0] rd_addr;
	reg mem_to_reg;
	reg reg_write;
	reg pc_to_reg;


	assign opcode_wb = opcode;
	assign func_code_wb = func_code;
	assign pc_wb = pc;
	assign alu_result_wb = alu_result;
	assign mem_data_wb = mem_data;
	assign forwarded_data1_wb = forwarded_data1;
	assign rd_addr_wb = rd_addr;

	assign mem_to_reg_wb = mem_to_reg;
	assign reg_write_wb = reg_write;
	assign pc_to_reg_wb = pc_to_reg;


	initial begin
		opcode = 0;
		func_code = 0;
		pc = 0;
		alu_result = 0;
		mem_data = 0;
		forwarded_data1 = 0;
		rd_addr = 0;

		mem_to_reg = 0;
		reg_write = 0;
		pc_to_reg = 0;
	end


	always @(posedge reset_n) begin
		opcode <= 0;
		func_code <= 0;
		pc <= 0;
		alu_result <= 0;
		mem_data <= 0;
		forwarded_data1 <= 0;
		rd_addr <= 0;

		mem_to_reg <= 0;
		reg_write <= 0;
		pc_to_reg <= 0;
	end


	always @(posedge clk) begin
		opcode <= new_opcode;
		func_code <= new_func_code;
		pc <= new_pc;
		alu_result <= new_alu_result;
		mem_data <= new_mem_data;
		forwarded_data1 <= new_forwarded_data1;
		rd_addr <= new_rd_addr;

		mem_to_reg <= new_mem_to_reg;
		reg_write <= new_reg_write;
		pc_to_reg <= new_pc_to_reg;
	end

endmodule
