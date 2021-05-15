`define NumBits 16

module TCPModule(
    A,
    C
);

input wire [`NumBits - 1 : 0] A;

output wire [`NumBits - 1 : 0] C;

assign C=~A+1;

endmodule


module SHLModule(
    A,
    C
);

input wire [`NumBits - 1 : 0] A;
output wire [`NumBits - 1 : 0] C;

assign C=(A<<<1);

endmodule


module SHRModule(
    A,
    C
);

input wire [`NumBits - 1 : 0] A;
output wire [`NumBits - 1 : 0] C;

assign C=($signed(A) >>> 1);

endmodule
