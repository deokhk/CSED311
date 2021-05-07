`define WORD_SIZE 16


module RegisterFile (clk, reset_n,
					  in_addr1, in_addr2, write_addr,
					  write_data, reg_write_signal,

					  reg_data1, reg_data2);

	input clk, reset_n;
	input [1:0] in_addr1; // younger
	input [1:0] in_addr2; // younger
	input [1:0] write_addr; // older
	input [`WORD_SIZE-1:0] write_data; // older
	input reg_write_signal; // older
	
	output [`WORD_SIZE-1:0] reg_data1;
	output [`WORD_SIZE-1:0] reg_data2;

    reg [15:0] registers [3:0];


    initial begin
        registers[0] = 0;
        registers[1] = 0;
        registers[2] = 0;
        registers[3] = 0;
    end


    assign reg_data1 = (in_addr1 == write_addr) ? write_data : registers[in_addr1];
    assign reg_data2 = (in_addr2 == write_addr) ? write_data : registers[in_addr2];


	always @(posedge reset_n) begin
        registers[0] <= 0;
        registers[1] <= 0;
        registers[2] <= 0;
        registers[3] <= 0;
	end


    always @(posedge clk) begin
        if (reg_write_signal) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule
