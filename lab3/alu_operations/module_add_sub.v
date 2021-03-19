`define NumBits 16


module ADDModule(
    A, B,
    C
);

input wire [`NumBits - 1 : 0] A;
input wire [`NumBits - 1 : 0] B;

output wire [`NumBits - 1 : 0] C;

assign C=A+B;

endmodule


module SUBModule(
    A, B,
    C
);

input wire [`NumBits - 1 : 0] A;
input wire [`NumBits - 1 : 0] B;

output wire [`NumBits - 1 : 0] C;

assign C= A + (~B + 1);

endmodule
