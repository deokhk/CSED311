`define NumBits 16


module NOTModule(
    A,
    C
);

input wire [`NumBits - 1 : 0] A;

output wire [`NumBits - 1 : 0] C;

assign C=~A;

endmodule


module ANDModule(
    A, B,
    C
);

input wire [`NumBits - 1 : 0] A;
input wire [`NumBits - 1 : 0] B;

output wire [`NumBits - 1 : 0] C;

assign C=A&B;

endmodule


module ORRModule(
    A, B,
    C
);

input wire [`NumBits - 1 : 0] A;
input wire [`NumBits - 1 : 0] B;

output wire [`NumBits - 1 : 0] C;

assign C=A|B;

endmodule
