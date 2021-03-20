`include "opcodes.v" 	   

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

	reg [`WORD_SIZE-1:0] PC;


	alu uut (.alu_result(address))
	register_file rf (.rt(data))
	// 컨트롤 모듈에서, SWD 면 -> writeM = 1
	// 끝나면 writeM  = 0

endmodule							  																		  