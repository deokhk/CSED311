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



	// combinational logic
	always @(*) begin
	// 컨트롤 모듈에서, SWD 면 -> writeM = 1
	// 끝나면 writeM  = 0
	// ackOutput == 0 이 되면, -> writeM  = 0
	// read 는 input ready 

	end



	// sequential logic 으로 pc, 다른 register 연산 수행
	always @(posedge clk) begin


	end

endmodule							  																		  