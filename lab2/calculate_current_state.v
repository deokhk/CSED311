
`include "vending_machine_def.v"
	

module calculate_current_state(
	i_input_coin,
	o_return_coin,
	i_select_item,
	item_price,
	coin_value,
	current_total,
	wait_time,
	
	current_total_nxt,
	o_available_item,
	o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin, o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;

	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] current_total_nxt;
	integer i;	

	reg [`kTotalBits-1:0] tmp_total;

    initial begin
		o_available_item <= 0;
		o_output_item <= 0;
	end

	
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		tmp_total = current_total;

		if (i_input_coin[`kNumCoins-1]) tmp_total = tmp_total + coin_value[`kNumCoins-1];
		if (i_input_coin[`kNumCoins-2]) tmp_total = tmp_total + coin_value[`kNumCoins-2];
		if (i_input_coin[`kNumCoins-3]) tmp_total = tmp_total + coin_value[`kNumCoins-3];

		if (o_return_coin[`kNumCoins-1]) tmp_total = tmp_total - coin_value[`kNumCoins-1];
		if (o_return_coin[`kNumCoins-2]) tmp_total = tmp_total - coin_value[`kNumCoins-2];
		if (o_return_coin[`kNumCoins-3]) tmp_total = tmp_total - coin_value[`kNumCoins-3];

		// NOTE: Assume that there is no case to select more than two items simultaneously
		if (i_select_item[`kNumItems-1] && (tmp_total >= item_price[`kNumItems-1])) tmp_total = tmp_total - item_price[`kNumItems-1];
		if (i_select_item[`kNumItems-2] && (tmp_total >= item_price[`kNumItems-2])) tmp_total = tmp_total - item_price[`kNumItems-2];
		if (i_select_item[`kNumItems-3] && (tmp_total >= item_price[`kNumItems-3])) tmp_total = tmp_total - item_price[`kNumItems-3];
		if (i_select_item[`kNumItems-4] && (tmp_total >= item_price[`kNumItems-4])) tmp_total = tmp_total - item_price[`kNumItems-4];

		current_total_nxt = tmp_total;
	end


	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		// TODO: o_output_item
		if (current_total >= item_price[`kNumItems-1]) o_available_item = 4'b1111;
		else if (current_total >= item_price[`kNumItems-2]) o_available_item = 4'b0111;
		else if (current_total >= item_price[`kNumItems-3]) o_available_item = 4'b0011;
		else if (current_total >= item_price[`kNumItems-4]) o_available_item = 4'b0001;
		else o_available_item = 4'b0000;

		// NOTE: Assume that there is no case to select more than two items simultaneously
		// Because, if current_total == 1400 and user select 1000 item and 500 item, which means required current_total > 1400
		// There is no guidelines in lab.pdf which one is out.
		if (i_select_item[`kNumItems-1] & o_available_item[`kNumItems-1]) o_output_item[`kNumItems-1] = 1; else o_output_item[`kNumItems-1] = 0;
		if (i_select_item[`kNumItems-2] & o_available_item[`kNumItems-2]) o_output_item[`kNumItems-2] = 1; else o_output_item[`kNumItems-2] = 0;
		if (i_select_item[`kNumItems-3] & o_available_item[`kNumItems-3]) o_output_item[`kNumItems-3] = 1; else o_output_item[`kNumItems-3] = 0;
		if (i_select_item[`kNumItems-4] & o_available_item[`kNumItems-4]) o_output_item[`kNumItems-4] = 1; else o_output_item[`kNumItems-4] = 0;

	end

endmodule 