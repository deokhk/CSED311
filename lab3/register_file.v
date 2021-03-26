module RegisterFile(in_addr1, in_addr2,
                     write_addr, write_data,
                     reg_write_signal, clk,

                     reg_data1, reg_data2); 
    output reg [15:0] reg_data1;
    output reg [15:0] reg_data2;

    input [1:0] in_addr1;
    input [1:0] in_addr2;
    input [1:0] write_addr;
    input [15:0] write_data;

    input reg_write_signal;
    input clk;

    reg [15:0] registers [3:0];

    initial begin
        registers[0] = 0;
        registers[1] = 0;
        registers[2] = 0;
        registers[3] = 0;

        reg_data1 = 0;
        reg_data2 = 0;
    end

    always @(*) begin
        case (in_addr1)
            2'b00: reg_data1 = registers[0];
            2'b01: reg_data1 = registers[1];
            2'b10: reg_data1 = registers[2];
            2'b11: reg_data1 = registers[3];
            default : reg_data1 = 0;
        endcase

        case (in_addr2)
            2'b00: reg_data2 = registers[0];
            2'b01: reg_data2 = registers[1];
            2'b10: reg_data2 = registers[2];
            2'b11: reg_data2 = registers[3];
            default : reg_data2 = 0;
        endcase
    end

    always @(posedge clk) begin

        if (reg_write_signal) begin
            case (write_addr)
                2'b00: registers[0] <= write_data;
                2'b01: registers[1] <= write_data;
                2'b10: registers[2] <= write_data;
                2'b11: registers[3] <= write_data;
                default : registers[0] <= 0;
            endcase
        end

    end

endmodule
