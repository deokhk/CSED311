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

	/////////////////  IF / ID reg /////////////////
	reg [`WORD_SIZE-1:0] pc_id;
	reg [`WORD_SIZE-1:0] inst_id;
	/////////////////  IF / ID reg /////////////////

	/////////////////  ID / EX reg /////////////////
	reg [`WORD_SIZE-1:0] pc_ex;
	reg [`WORD_SIZE-1:0] reg_data1_ex;
	reg [`WORD_SIZE-1:0] reg_data2_ex;
	reg [`WORD_SIZE-1:0] extended_output_ex;
	reg [1:0] reg_write_addr_ex;
	/////////////////  ID / EX reg /////////////////

	/////////////////  EX / MEM reg /////////////////
	reg [`WORD_SIZE-1:0] next_pc_mem;
	reg [`WORD_SIZE-1:0] bcond_mem;
	reg [`WORD_SIZE-1:0] alu_out_mem;
	reg [`WORD_SIZE-1:0] reg_data2_mem;
	reg [1:0] reg_write_addr_mem;
	/////////////////  EX / MEM reg /////////////////

	/////////////////  MEM / WB reg /////////////////
	reg [`WORD_SIZE-1:0] mem_data_wb;
	reg [`WORD_SIZE-1:0] alu_out_wb;
	reg [1:0] reg_write_addr_wb;
	/////////////////  MEM / WB reg /////////////////


	always@(posedge clk) {
		if (is_J_B_taken) {
			// IF/ID stage reg 에 있는 control value 들을 0으로 
			// pc_id <= 0;

			// ID/EX stage reg 에 있는 control value 들을 0 으로
			pc_ex <= 0;

		}
	}

endmodule


