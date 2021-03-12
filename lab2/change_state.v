`include "vending_machine_def.v"


module change_state(
	clk,
	reset_n,
	current_total_nxt,
	available_item_nxt,
	output_item_nxt,
	return_coin_nxt,
	
	current_total,
	o_available_item,
	o_output_item,
	o_return_coin);

	input clk;
	input reset_n;
	input [`kTotalBits-1:0] current_total_nxt;
	input [`kNumItems-1:0] available_item_nxt;
	input [`kNumItems-1:0] output_item_nxt;
	input [`kNumCoins-1:0] return_coin_nxt;
	
	output reg [`kTotalBits-1:0] current_total;
	output reg [`kNumItems-1:0] o_available_item;
	output reg [`kNumItems-1:0] o_output_item;
	output reg [`kNumCoins-1:0] o_return_coin;
	
	// Sequential circuit to reset or update the states

	// posedge 가 뜰 때, current_total, available item, output_item 업데이트
	always @(posedge clk ) begin
		if (!reset_n) begin
			current_total <= 0;
			o_available_item <= 0;
			o_output_item <= 0;
			o_return_coin <= 0;
		end
		else begin
			current_total <= current_total_nxt;
			o_available_item <= available_item_nxt;
			o_output_item <= output_item_nxt;
			o_return_coin <= return_coin_nxt;
		end
	end
endmodule 