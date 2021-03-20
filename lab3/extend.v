module sign_extend_8_to_16(in, out);
    input wire [7:0] in;
    output wire [15:0] out;

    assign out = {8in[7], in[7:0]};
endmodule


module msb_zero_extend_8_to_16(in, out);
    input wire [7:0] in;
    output wire [15:0] out;

    assign out = {8'b00000000,in[7:0]};

endmodule


module lsb_zero_extend_8_to_16(in, out);
    input wire [7:0] in;
    output wire [15:0] out;

    assign out = {in[7:0],8'b00000000};

endmodule


module concat_pc_4_target_12(pc, target, out);
    input wire [15:0] pc;
    input wire [11:0] target;
    output wire [15:0] out;

    assign out = {pc[15:12], target[11:0]};

endmodule
