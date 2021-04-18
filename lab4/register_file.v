module RegisterFile(in_addr1, in_addr2,
                     write_addr, write_data,
                     reg_write_signal, clk,

                     reg_data1, reg_data2, registers); 
    output [15:0] reg_data1;
    output [15:0] reg_data2;

    input [1:0] in_addr1;
    input [1:0] in_addr2;
    input [1:0] write_addr;
    input [15:0] write_data;

    input reg_write_signal;
    input clk;

    output reg [15:0] registers [3:0];

    initial begin
        registers[0] = 0;
        registers[1] = 0;
        registers[2] = 0;
        registers[3] = 0;
    end

    assign reg_data1 = registers[in_addr1];
    assign reg_data2 = registers[in_addr2];


    always @(posedge clk) begin
        if (reg_write_signal) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule
