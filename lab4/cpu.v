`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "opcodes.v"
`include "alu.v"
`include "micro_code_controller.v"
`include "register_file.v"
`include "util.v"


module cpu(clk, reset_n, read_m, write_m, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output read_m;
	output write_m;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output [`WORD_SIZE-1:0] num_inst;		// number of instruction executed (for testing purpose)
	output [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;

	// TODO : implement multi-cycle CPU

    wire [3:0] opcode;
    wire [5:0] func_code;

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
    wire next_pc_write_en;

    wire alu_opcode;
    wire wb_sel;
	wire [`WORD_SIZE-1:0] num_inst_from_micro_controller;


	reg [`WORD_SIZE-1:0] PC;
	reg [`WORD_SIZE-1:0] nextPC;
	reg [`WORD_SIZE-1:0] inst_reg;
	reg [`WORD_SIZE-1:0] mem_data_reg;
	reg [`WORD_SIZE-1:0] A_reg;
	reg [`WORD_SIZE-1:0] B_reg;
	reg [`WORD_SIZE-1:0] ALUOut_reg;
	reg bcond_reg;


	assign data = write_m ? B_reg : `WORD_SIZE'bz;


    initial begin
		PC = 0;
		nextPC = 0;
		inst_reg = 0;
		mem_data_reg = 0;
		A_reg = 0;
		B_reg = 0;
		ALUOut_reg = 0;
		bcond_reg = 0;
    end
	
	// TODO: mem_read, mem_write, num_inst assign

	mux2_1 i_or_d_mux (
		.sel(i_or_d), .i1(PC), .i2(*************),
		
		.o(address)
	);
	mux2_1 mem_to_reg_mux (
		.sel(), .i1(), .i2(),
		
		.o()
	);
	mux2_1 alu_src_a_mux (
		.sel(), .i1(), .i2(),
		
		.o()
	);
	mux2_1 next_pc_mux (
		.sel(), .i1(), .i2(),
		
		.o()
	);
	mux2_1 write_back_mux (
		.sel(), .i1(), .i2(),
		
		.o()
	);
	mux4_1 alu_src_b_mux (
		.sel(), .i1(), .i2(), .i3(), .i4(),
		
		.o()
	);

    MicroCodeController micro_code_controller (
		.opcode(opcode), .func_code(func_code), .reset_n(reset_n), .clk(clk),

		.mem_read(mem_read), .mem_to_reg(mem_to_reg), .mem_write(mem_write), .reg_write(reg_write),
		.alu_src_a(alu_src_a), .alu_src_b(alu_src_b),
		.i_or_d(i_or_d), .ir_write(ir_write), .dr_write(dr_write),
		.pc_source(pc_source), .pc_write(pc_write), 
		.wwd(wwd), .halt(halt), .pass_input_1(pass_input_1), .pass_input_2(pass_input_2),
		.A_write_en(A_write_en), .B_write_en(B_write_en),
		.bcond_write_en(bcond_write_en), .aluout_write_en(aluout_write_en), .next_pc_write_en(next_pc_write_en),
		.alu_opcode(alu_opcode), .wb_sel(wb_sel),
		.num_inst(num_inst_from_micro_controller)
	);



    ALU alu (
		.alu_input_1(reg_data1), .alu_input_2(alu_src_data),
		.pass_input_1(pass_input_1), .pass_input_2(pass_input_2),
		.opcode(alu_opcode), .func_code(func_code),
			
		.alu_output(alu_output), .bcond(bcond)
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



	initial begin
	end


	always @(data) begin
		if ((i_or_d == 0) && (ir_write == 1)) begin
			// PC supplies inst addr && IR latching enabled
			inst_reg = data;
		end
		if ((i_or_d == 1) && (dr_write == 1)) begin
			mem_data_reg = data;
		end
	end


	always @(posedge reset_n) begin
	end




endmodule
