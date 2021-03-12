
`include "vending_machine_def.v"
	

module calculate_current_state(
	i_input_coin,
	i_select_item,
	o_return_coin,
	i_trigger_return,
	return_flag,
	item_price,
	coin_value,
	current_total,
	now_available_item, // 현재 스테이트에서 available 한 아이템들
	
	current_total_nxt,
	available_item_nxt,
	output_item_nxt,
	return_coin_nxt);


	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input [`kNumCoins-1:0] o_return_coin;
	input i_trigger_return;
	input return_flag;

	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [`kNumItems-1:0] now_available_item;

	output reg [`kTotalBits-1:0] current_total_nxt;
	output reg [`kNumItems-1:0] available_item_nxt;
    output reg [`kNumItems-1:0] output_item_nxt;
	output reg [`kNumCoins-1:0] return_coin_nxt;
	integer i;

	reg [`kTotalBits-1:0] tmp_total_for_current;
	reg [`kTotalBits-1:0] tmp_total_for_return;

    initial begin
		current_total_nxt <= 0;
		available_item_nxt <= 0;
		output_item_nxt <= 0;
		return_coin_nxt <= 0;
	end

	
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		tmp_total_for_current = current_total;

		if (i_input_coin[`kNumCoins-1]) tmp_total_for_current = tmp_total_for_current + coin_value[`kNumCoins-1];
		if (i_input_coin[`kNumCoins-2]) tmp_total_for_current = tmp_total_for_current + coin_value[`kNumCoins-2];
		if (i_input_coin[`kNumCoins-3]) tmp_total_for_current = tmp_total_for_current + coin_value[`kNumCoins-3];

		if (o_return_coin[`kNumCoins-1]) tmp_total_for_current = tmp_total_for_current - coin_value[`kNumCoins-1];
		if (o_return_coin[`kNumCoins-2]) tmp_total_for_current = tmp_total_for_current - coin_value[`kNumCoins-2];
		if (o_return_coin[`kNumCoins-3]) tmp_total_for_current = tmp_total_for_current - coin_value[`kNumCoins-3];

		// NOTE: Assume that there is no case to select more than two items simultaneously
		if (i_select_item[`kNumItems-1] & now_available_item[`kNumItems-1]) tmp_total_for_current = tmp_total_for_current - item_price[`kNumItems-1];
		if (i_select_item[`kNumItems-2] & now_available_item[`kNumItems-2]) tmp_total_for_current = tmp_total_for_current - item_price[`kNumItems-2];
		if (i_select_item[`kNumItems-3] & now_available_item[`kNumItems-3]) tmp_total_for_current = tmp_total_for_current - item_price[`kNumItems-3];
		if (i_select_item[`kNumItems-4] & now_available_item[`kNumItems-4]) tmp_total_for_current = tmp_total_for_current - item_price[`kNumItems-4];

		current_total_nxt = tmp_total_for_current;


		if (i_trigger_return | return_flag) begin
			tmp_total_for_return = current_total_nxt;
			if (tmp_total_for_return >= 1000) begin
				tmp_total_for_return = tmp_total_for_return - 1000;
				return_coin_nxt[`kNumCoins-1] = 1;
				end
			else
				return_coin_nxt[`kNumCoins-1] = 0;

			if (tmp_total_for_return >= 500) begin
				tmp_total_for_return = tmp_total_for_return - 500;
				return_coin_nxt[`kNumCoins-2] = 1;
				end
			else
				return_coin_nxt[`kNumCoins-2] = 0;

			if (tmp_total_for_return >= 100) begin
				tmp_total_for_return = tmp_total_for_return - 100;
				return_coin_nxt[`kNumCoins-3] = 1;
				end
			else
				return_coin_nxt[`kNumCoins-3] = 0;

		end
		else
			return_coin_nxt = 0;


		// if (current_total_nxt >= item_price[`kNumItems-1]) available_item_nxt = 4'b1111;
		// else if (current_total_nxt >= item_price[`kNumItems-2]) available_item_nxt = 4'b0111;
		// else if (current_total_nxt >= item_price[`kNumItems-3]) available_item_nxt = 4'b0011;
		// else if (current_total_nxt >= item_price[`kNumItems-4]) available_item_nxt = 4'b0001;
		// else available_item_nxt = 4'b0000;


		// if (i_select_item[`kNumItems-1] & available_item_nxt[`kNumItems-1]) output_item_nxt[`kNumItems-1] = 1; else output_item_nxt[`kNumItems-1] = 0;
		// if (i_select_item[`kNumItems-2] & available_item_nxt[`kNumItems-2]) output_item_nxt[`kNumItems-2] = 1; else output_item_nxt[`kNumItems-2] = 0;
		// if (i_select_item[`kNumItems-3] & available_item_nxt[`kNumItems-3]) output_item_nxt[`kNumItems-3] = 1; else output_item_nxt[`kNumItems-3] = 0;
		// if (i_select_item[`kNumItems-4] & available_item_nxt[`kNumItems-4]) output_item_nxt[`kNumItems-4] = 1; else output_item_nxt[`kNumItems-4] = 0;

	end


	// Combinational logic for the outputs
	always @(*) begin

		if (current_total >= item_price[`kNumItems-1]) available_item_nxt = 4'b1111;
		else if (current_total >= item_price[`kNumItems-2]) available_item_nxt = 4'b0111;
		else if (current_total >= item_price[`kNumItems-3]) available_item_nxt = 4'b0011;
		else if (current_total >= item_price[`kNumItems-4]) available_item_nxt = 4'b0001;
		else available_item_nxt = 4'b0000;

		// NOTE: Assume that there is no case to select more than two items simultaneously
		// Because, if current_total == 1400 and user select 1000 item and 500 item, which means required current_total > 1400
		// There is no guidelines in lab.pdf which one is out.
		if (i_select_item[`kNumItems-1] & now_available_item[`kNumItems-1]) output_item_nxt[`kNumItems-1] = 1; else output_item_nxt[`kNumItems-1] = 0;
		if (i_select_item[`kNumItems-2] & now_available_item[`kNumItems-2]) output_item_nxt[`kNumItems-2] = 1; else output_item_nxt[`kNumItems-2] = 0;
		if (i_select_item[`kNumItems-3] & now_available_item[`kNumItems-3]) output_item_nxt[`kNumItems-3] = 1; else output_item_nxt[`kNumItems-3] = 0;
		if (i_select_item[`kNumItems-4] & now_available_item[`kNumItems-4]) output_item_nxt[`kNumItems-4] = 1; else output_item_nxt[`kNumItems-4] = 0;

	end

endmodule 