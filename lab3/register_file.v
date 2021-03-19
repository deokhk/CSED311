module register_file(read_out1, read_out2,
                     read1, read2, write_reg, write_data, reg_write_signal, clk); 
    output reg [15:0] read_out1; // data
    output reg [15:0] read_out2; // data

    input [1:0] read1; // address
    input [1:0] read2; // address
    input [1:0] write_reg; // address
    input [15:0] write_data; // data
    input reg_write_signal;
    input clk;

    reg [15:0] registers [3:0];

    initial begin
        registers[0] = 0;
        registers[1] = 0;
        registers[2] = 0;
        registers[3] = 0;

        read_out1 = 0;
        read_out2 = 0;
    end

    always @(*) begin
        case (read1)
            2'b00: read_out1 = registers[0];
            2'b01: read_out1 = registers[1];
            2'b10: read_out1 = registers[2];
            2'b11: read_out1 = registers[3];
            default : read_out1 = 0;
        endcase

        case (read2)
            2'b00: read_out2 = registers[0];
            2'b01: read_out2 = registers[1];
            2'b10: read_out2 = registers[2];
            2'b11: read_out2 = registers[3];
            default : read_out2 = 0;
        endcase
    end

    always @(posedge clk) begin

        if (reg_write_signal) begin
            case (write_reg)
                2'b00: registers[0] <= write_data;
                2'b01: registers[1] <= write_data;
                2'b10: registers[2] <= write_data;
                2'b11: registers[3] <= write_data;
                default : registers[0] <= 0;
            endcase
        end

    end

endmodule
