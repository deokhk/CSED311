`define	NumBits	16


module Mux2to1 (in0, in1, sel,
                   out);
    input wire [`NumBits-1:0] in0;
    input wire [`NumBits-1:0] in1;
    input wire sel;
    output wire [`NumBits-1:0] out;

    assign out = sel ? in1 : in0;

endmodule


module Mux3to1 (in0, in1, in2, sel,
                   out);
    input wire [`NumBits-1:0] in0;
    input wire [`NumBits-1:0] in1;
    input wire [`NumBits-1:0] in2;
    input wire [1:0] sel;
    output wire [`NumBits-1:0] out;

    assign out = sel[1] ? in2 : (sel[0] ? in1 : in0);

endmodule
