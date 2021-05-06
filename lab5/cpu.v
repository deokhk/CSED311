`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "datapath.v"

module cpu(clk, reset_n,
		   data1,
		   data2, // inout

		   read_m1, address1, read_m2, write_m2, address2,
		   
		    num_inst, output_port, is_halted);

	input clk;
	input reset_n;

	input [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;

	output read_m1;
	output [`WORD_SIZE-1:0] address1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] address2;

	output [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	output is_halted;

	//TODO: implement pipelined CPU

	// JorBTaken 을 control_hazard_flush 로 assign

	always@(posedge clk) {
		if (is_J_B_taken) {
			// IF/ID stage reg 에 있는 control value 들을 0으로 
			// pc_id <= 0;

			// ID/EX stage reg 에 있는 control value 들을 0 으로
			pc_ex <= 0;

		}
	}

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
					new_pc, new_reg_data1, new_reg_data2,
					new_extended_output, new_rd_addr,
					new_is_branch, new_is_jmp_jal, new_is_jpr_jrl,
					new_mem_read, new_mem_to_reg, new_mem_write,
					new_alu_src, new_reg_write, new_pc_to_reg,
					data_hazard_stall, control_hazard_flush,

					opcode_ex, func_code_ex,
					pc_ex, reg_data1_ex, reg_data2_ex,
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
					 new_pc_candidate, new_bcond, new_alu_result,
					 new_forwarded_data1, new_forwarded_data2, new_rd_addr,
					 new_is_branch, new_is_jmp_jal, new_is_jpr_jrl,
					 new_mem_read, new_mem_to_reg,
					 new_mem_write, new_reg_write, new_pc_to_reg,
					 control_hazard_flush,
					 
					 opcode_mem, func_code_mem,
 					 pc_candidate_mem, bcond_mem, alu_result_mem,
					 forwarded_data1_mem, forwarded_data2_mem, rd_addr_mem,
					 is_branch_mem, is_jmp_jal_mem, is_jpr_jrl_mem,
					 mem_read_mem, mem_to_reg_mem, mem_write_mem,
					 reg_write_mem, pc_to_reg_mem);

	
	input wire clk;
	input wire reset_n;
	input wire [3:0] new_opcode;
	input wire [5:0] new_func_code;
	input wire [`WORD_SIZE-1:0] new_pc_candidate;
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
	output wire [`WORD_SIZE-1:0] pc_candidate_mem;
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
	reg [`WORD_SIZE-1:0] pc_candidate;
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
	assign pc_candidate_mem = pc_candidate;
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
		pc_candidate = 0;
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
		pc_candidate <= 0;
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
			pc_candidate <= new_pc_candidate;
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
