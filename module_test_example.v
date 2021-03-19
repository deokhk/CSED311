// https://www.jdoodle.com/execute-verilog-online/
// Test module!

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


module jdoodle;

    reg [`NumBits-1:0] in0;
    reg [`NumBits-1:0] in1;
    reg [`NumBits-1:0] in2;
    reg [1:0] sel;
    wire [`NumBits-1:0] out;
    
    mux_3_to_1 mux31(in0, in1, in2, sel, out);

    initial begin
        $display ("Welcome to JDoodle!!!");
        
        in0 = 10;
        in1 = 20;
        in2 = 30;
        
        sel = 0;
        #2 $display ("%d", out);

        sel = 1;
        #2 $display ("%d", out);

        sel = 2;
        #2 $display ("%d", out);
        
        $finish;
    end
endmodule