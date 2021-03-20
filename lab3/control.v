
module control ();

endmodule


module pc_mux_selector(is_branch, is_jmp_jal, is_jpr_jrl, bcond,
                        
                       pc_mux_sel);

input wire is_branch;
input wire is_jmp_jal;
input wire is_jpr_jrl;
input wire bcond;

output reg [1:0] pc_mux_sel;

always @ (*) begin
    if (is_branch & bcond) 
        pc_mux_sel = 2'b01;
    else if (is_jmp_jal)
        pc_mux_sel = 2'b10;
    else if (is_jpr_jrl)
        pc_mux_sel = 2'b11;
    else
        pc_mux_sel = 2'b00;
end

endmodule


