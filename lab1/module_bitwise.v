`include "alu_func.v"

`define data_width 16


module NOTModule(
    A,
    C
);

input wire [`data_width - 1 : 0] A;

output wire [`data_width - 1 : 0] C;

assign C=~A;

endmodule


module ANDModule(
    A, B,
    C
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;

assign C=A&B;

endmodule


module ORModule(
    A, B,
    C
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;

assign C=A|B;

endmodule


module NANDModule(
    A, B,
    C
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;

assign C=~(A&B);

endmodule


module NORModule(
    A, B,
    C
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;

assign C=~(A|B);

endmodule


module XORModule(
    A, B,
    C
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;

assign C=A^B;

endmodule


module XNORModule(
    A, B,
    C
);

input wire [`data_width - 1 : 0] A;
input wire [`data_width - 1 : 0] B;

output wire [`data_width - 1 : 0] C;

assign C=~(A^B);

endmodule
