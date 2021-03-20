`include "opcodes.v" 	   

module cpu (data, ackOutput, inputReady,
			reset_n, clk,

			readM, writeM, address);
	output readM;									
	output writeM;								
	output [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;


	reg [`WORD_SIZE-1:0] PC;


endmodule							  																		  