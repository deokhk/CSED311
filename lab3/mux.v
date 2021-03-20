`define	NumBits	16


module mux_2_to_1 (in0, in1, sel,
                   out);
    input wire [`NumBits-1:0] in0;
    input wire [`NumBits-1:0] in1;
    input wire sel;
    output wire [`NumBits-1:0] out;

    assign out = sel ? in1 : in0;

endmodule


module mux_3_to_1 (in0, in1, in2, sel,
                   out);
    input wire [`NumBits-1:0] in0;
    input wire [`NumBits-1:0] in1;
    input wire [`NumBits-1:0] in2;
    input wire [1:0] sel;
    output wire [`NumBits-1:0] out;

    assign out = sel[1] ? in2 : (sel[0] ? in1 : in0);

endmodule


module mux_4_to_1 (in0, in1, in2, in3, sel,
                   out);
    input wire [`NumBits-1:0] in0; // 00
    input wire [`NumBits-1:0] in1; // 01
    input wire [`NumBits-1:0] in2; // 10
    input wire [`NumBits-1:0] in3; // 11
    input wire [1:0] sel;
    output wire [`NumBits-1:0] out;

    assign out = sel[1] ? (sel[0] ? in3 : in2) : (sel[0] ? in1 : in0);

endmodule
