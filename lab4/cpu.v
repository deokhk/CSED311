`timescale 1ns/1ns

`include "opcodes.v"
`include "extend.v"
`include "inst_parser.v"
`include "micro_code_controller.v"
`include "register_file.v"
`include "util.v"
`include "alu.v"


module cpu(clk, reset_n, read_m, write_m, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output read_m;
	output write_m;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output [`WORD_SIZE-1:0] num_inst;		// number of instruction executed (for testing purpose)
	output reg [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;


	// Inst Parser
    wire [3:0] opcode;
	wire [1:0] in_addr1;
	wire [1:0] in_addr2;
	wire [1:0] write_addr;
    wire [5:0] func_code;
	wire [7:0] immediate_and_offset;
	wire [11:0] target_address;

	// Register File
	wire [15:0] reg_data1;
    wire [15:0] reg_data2;
	wire [15:0] write_data;

	// Extend Delegator
	wire [`WORD_SIZE-1:0] extended_output;

	// ALU
	wire [15:0] alu_src_a_out;
	wire [15:0] alu_src_b_out;
	wire [15:0] alu_result;
	wire overflow_flag;
	wire bcond;
	
	// WB MUX
	wire [15:0] wb_out;

	// next pc MUX
	wire [15:0] next_pc_out;

	wire [`WORD_SIZE-1:0] i_or_d_out;

    wire mem_read;
    wire mem_to_reg;
    wire mem_write;
    wire reg_write;

    wire alu_src_a;
    wire [1:0] alu_src_b;

    wire i_or_d; 
    wire ir_write;
    wire dr_write;

    wire pc_source;
    wire pc_write;
    
    wire wwd;
    wire halt;

    wire pass_input_1;
    wire pass_input_2;

    wire A_write_en;
    wire B_write_en;
    wire bcond_write_en;
    wire aluout_write_en;
    wire next_pc_reg_write_en;
    wire wb_out_reg_write_en;

    wire [3:0] alu_opcode;
    wire wb_sel;
	wire pc_mux_sel;
	wire [`WORD_SIZE-1:0] num_inst_from_micro_controller;


	reg [`WORD_SIZE-1:0] pc;
	reg [`WORD_SIZE-1:0] next_pc_reg;
	reg [`WORD_SIZE-1:0] one;
	reg [`WORD_SIZE-1:0] inst_reg;
	reg [`WORD_SIZE-1:0] mem_data_reg;
	reg [`WORD_SIZE-1:0] A_reg;
	reg [`WORD_SIZE-1:0] B_reg;
	reg [`WORD_SIZE-1:0] ALUOut_reg;
	reg bcond_reg;
	reg [`WORD_SIZE-1:0] wb_out_reg;

    initial begin
		pc = 0;
		next_pc_reg = 0;
		one = 1;
		inst_reg = 0;
		mem_data_reg = 0;
		A_reg = 0;
		B_reg = 0;
		ALUOut_reg = 0;
		bcond_reg = 0;
		wb_out_reg = 0;

		output_port = 0;
    end
	

	mux2_1 i_or_d_mux (
		.sel(i_or_d), .i1(pc), .i2(wb_out_reg),
		
		.o(i_or_d_out)
	);
	mux2_1 mem_to_reg_mux (
		.sel(mem_to_reg), .i1(wb_out_reg), .i2(mem_data_reg),
		
		.o(write_data)
	);
	mux2_1 alu_src_a_mux (
		.sel(alu_src_a), .i1(pc), .i2(A_reg),
		
		.o(alu_src_a_out)
	);
	mux4_1 alu_src_b_mux (
		.sel(alu_src_b), .i1(B_reg), .i2(one), .i3(extended_output), .i4(one),
		
		.o(alu_src_b_out)
	);
	mux2_1 next_pc_mux (
		.sel(pc_mux_sel), .i1(alu_result), .i2(ALUOut_reg),
		
		.o(next_pc_out)
	);
	mux2_1 write_back_mux (
		.sel(wb_sel), .i1(ALUOut_reg), .i2(alu_result),
		
		.o(wb_out)
	);

	assign data = write_m ? B_reg : `WORD_SIZE'bz;
	assign is_halted = halt;
	assign read_m = mem_read;
	assign write_m = mem_write;
	assign address = i_or_d_out;
	assign num_inst = num_inst_from_micro_controller;


    MicroCodeController micro_code_controller (
		.opcode(opcode), .func_code(func_code), .reset_n(reset_n), .clk(clk),

		.mem_read(mem_read), .mem_to_reg(mem_to_reg), .mem_write(mem_write), .reg_write(reg_write),
		.alu_src_a(alu_src_a), .alu_src_b(alu_src_b),
		.i_or_d(i_or_d), .ir_write(ir_write), .dr_write(dr_write),
		.pc_source(pc_source), .pc_write(pc_write), 
		.wwd(wwd), .halt(halt), .pass_input_1(pass_input_1), .pass_input_2(pass_input_2),
		.A_write_en(A_write_en), .B_write_en(B_write_en),
		.bcond_write_en(bcond_write_en), .aluout_write_en(aluout_write_en), .next_pc_reg_write_en(next_pc_reg_write_en), .wb_out_reg_write_en(wb_out_reg_write_en),
		.alu_opcode(alu_opcode), .wb_sel(wb_sel),
		.num_inst(num_inst_from_micro_controller)
	);

	PCMuxSelector pc_mux_selector (
		.pc_source(pc_source), .bcond(bcond_reg), .opcode(opcode),
        
		.pc_mux_sel(pc_mux_sel)
	);

	InstParser inst_parser (
		.inst(inst_reg),
                    
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

    ALU alu (
		.alu_input_1(alu_src_a_out), .alu_input_2(alu_src_b_out),
		.pass_input_1(pass_input_1), .pass_input_2(pass_input_2),
		.opcode(alu_opcode), .func_code(func_code),

		.alu_result(alu_result), .overflow_flag(overflow_flag), .bcond(bcond)
	);


	always @(posedge clk) begin
		if ((i_or_d == 0) && (ir_write == 1)) begin
			// pc supplies inst addr && IR latching enabled
			inst_reg <= data;
		end
		if ((i_or_d == 1) && (dr_write == 1)) begin
			mem_data_reg <= data;
		end
	end

	always @(posedge clk) begin
		if (A_write_en == 1) begin
			A_reg <= reg_data1;
		end
		if (B_write_en == 1) begin
			B_reg <= reg_data2;
		end
	end

	always @(posedge clk) begin
		if (aluout_write_en == 1) begin
			ALUOut_reg <= alu_result;
		end
		if (bcond_write_en == 1) begin
			bcond_reg <= bcond;
		end
	end

	always @(posedge clk) begin
		if (next_pc_reg_write_en == 1) begin
			if ((opcode >= `BNE_OP) && (opcode <= `BLZ_OP) && (bcond_reg == 1)) begin
				next_pc_reg <= next_pc_out + 1;
			end
			else begin
				next_pc_reg <= next_pc_out;
			end
			// next_pc_reg <= next_pc_out;
		end
	end

	always @(posedge clk) begin
		if (pc_write == 1) begin
			pc <= next_pc_reg;
		end
	end

	always @(posedge clk) begin
		if (wb_out_reg_write_en == 1) begin
			wb_out_reg <= wb_out;
		end
	end


	always @(posedge clk) begin
		if (wwd == 1) begin
			output_port <= A_reg;
		end
	end

	always @(posedge reset_n) begin
		pc <= 0;
		next_pc_reg <= 0;
		one <= 1;
		inst_reg <= 0;
		mem_data_reg <= 0;
		A_reg <= 0;
		B_reg <= 0;
		ALUOut_reg <= 0;
		bcond_reg <= 0;
		wb_out_reg <= 0;

		output_port <= 0;
	end

endmodule
