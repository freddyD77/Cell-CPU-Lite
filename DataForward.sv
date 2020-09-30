/* Module implementing Data forwarding from the execution pipes
 * Purely combinational block and comes right after the register file to make sure that correct values are only pushed as operands to the execution pipes
 */
module DataForward(
	input			[0:134]		data_ra_0, data_rb_0, data_rc_0,
	input			[0:134]		data_ra_1, data_rb_1, data_rc_1,
	input			[0:138]		fwe2_out, fwe3_out, fwe4_out, fwe5_out, fwe6_out, fwe7_out, rf_wbe_out,
	input			[0:138]		fwo1_out, fwo2_out, fwo3_out, fwo4_out, fwo5_out, fwo6_out, fwo7_out, rf_wbo_out,
	output logic	[0:127]		data_out_ra_0, data_out_rb_0, data_out_rc_0, data_out_ra_1, data_out_rb_1, data_out_rc_1);

	always_comb begin
		
		data_out_ra_0 = data_ra_0[0:127];
		data_out_rb_0 = data_rb_0[0:127];
		data_out_rc_0 = data_rc_0[0:127];
		data_out_ra_1 = data_ra_1[0:127];
		data_out_rb_1 = data_rb_1[0:127];
		data_out_rc_1 = data_rc_1[0:127];


		// Data Forwarding data_ra for even pipe
		if(rf_wbe_out[131] == 1 & rf_wbe_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = rf_wbe_out[0:127];
		if(rf_wbo_out[131] == 1 & rf_wbo_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = rf_wbo_out[0:127];
		if(fwe7_out[131] == 1 & fwe7_out[128:130] <= 3'd7 & fwe7_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwe7_out[0:127];
		if(fwo7_out[131] == 1 & fwo7_out[128:130] <= 3'd7 & fwo7_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwo7_out[0:127];
		if(fwe6_out[131] == 1 & fwe6_out[128:130] <= 3'd6 & fwe6_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwe6_out[0:127];
		if(fwo6_out[131] == 1 & fwo6_out[128:130] <= 3'd6 & fwo6_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwo6_out[0:127];
		if(fwe5_out[131] == 1 & fwe5_out[128:130] <= 3'd5 & fwe5_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwe5_out[0:127];
		if(fwo5_out[131] == 1 & fwo5_out[128:130] <= 3'd5 & fwo5_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwo5_out[0:127];
		if(fwe4_out[131] == 1 & fwe4_out[128:130] <= 3'd4 & fwe4_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwe4_out[0:127];
		if(fwo4_out[131] == 1 & fwo4_out[128:130] <= 3'd4 & fwo4_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwo4_out[0:127];
		if(fwe3_out[131] == 1 & fwe3_out[128:130] <= 3'd3 & fwe3_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwe3_out[0:127];
		if(fwo3_out[131] == 1 & fwo3_out[128:130] <= 3'd3 & fwo3_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwo3_out[0:127];
		if(fwe2_out[131] == 1 & fwe2_out[128:130] <= 3'd2 & fwe2_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwe2_out[0:127];
		if(fwo2_out[131] == 1 & fwo2_out[128:130] <= 3'd2 & fwo2_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwo2_out[0:127];
		if(fwo1_out[131] == 1 & fwo1_out[128:130] <= 3'd1 & fwo1_out[132:138] == data_ra_0[128:134]) data_out_ra_0 = fwo1_out[0:127];

		// Data Forwarding data_rb for even pipe
		if(rf_wbe_out[131] == 1 & rf_wbe_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = rf_wbe_out[0:127];
		if(rf_wbo_out[131] == 1 & rf_wbo_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = rf_wbo_out[0:127];
		if(fwe7_out[131] == 1 & fwe7_out[128:130] <= 3'd7 & fwe7_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwe7_out[0:127];
		if(fwo7_out[131] == 1 & fwo7_out[128:130] <= 3'd7 & fwo7_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwo7_out[0:127];
		if(fwe6_out[131] == 1 & fwe6_out[128:130] <= 3'd6 & fwe6_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwe6_out[0:127];
		if(fwo6_out[131] == 1 & fwo6_out[128:130] <= 3'd6 & fwo6_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwo6_out[0:127];
		if(fwe5_out[131] == 1 & fwe5_out[128:130] <= 3'd5 & fwe5_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwe5_out[0:127];
		if(fwo5_out[131] == 1 & fwo5_out[128:130] <= 3'd5 & fwo5_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwo5_out[0:127];
		if(fwe4_out[131] == 1 & fwe4_out[128:130] <= 3'd4 & fwe4_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwe4_out[0:127];
		if(fwo4_out[131] == 1 & fwo4_out[128:130] <= 3'd4 & fwo4_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwo4_out[0:127];
		if(fwe3_out[131] == 1 & fwe3_out[128:130] <= 3'd3 & fwe3_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwe3_out[0:127];
		if(fwo3_out[131] == 1 & fwo3_out[128:130] <= 3'd3 & fwo3_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwo3_out[0:127];
		if(fwe2_out[131] == 1 & fwe2_out[128:130] <= 3'd2 & fwe2_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwe2_out[0:127];
		if(fwo2_out[131] == 1 & fwo2_out[128:130] <= 3'd2 & fwo2_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwo2_out[0:127];
		if(fwo1_out[131] == 1 & fwo1_out[128:130] <= 3'd1 & fwo1_out[132:138] == data_rb_0[128:134]) data_out_rb_0 = fwo1_out[0:127];
		
		// Data Forwarding data_rc for even pipe
		if(rf_wbe_out[131] == 1 & rf_wbe_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = rf_wbe_out[0:127];
		if(rf_wbo_out[131] == 1 & rf_wbo_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = rf_wbo_out[0:127];
		if(fwe7_out[131] == 1 & fwe7_out[128:130] <= 3'd7 & fwe7_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwe7_out[0:127];
		if(fwo7_out[131] == 1 & fwo7_out[128:130] <= 3'd7 & fwo7_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwo7_out[0:127];
		if(fwe6_out[131] == 1 & fwe6_out[128:130] <= 3'd6 & fwe6_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwe6_out[0:127];
		if(fwo6_out[131] == 1 & fwo6_out[128:130] <= 3'd6 & fwo6_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwo6_out[0:127];
		if(fwe5_out[131] == 1 & fwe5_out[128:130] <= 3'd5 & fwe5_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwe5_out[0:127];
		if(fwo5_out[131] == 1 & fwo5_out[128:130] <= 3'd5 & fwo5_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwo5_out[0:127];
		if(fwe4_out[131] == 1 & fwe4_out[128:130] <= 3'd4 & fwe4_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwe4_out[0:127];
		if(fwo4_out[131] == 1 & fwo4_out[128:130] <= 3'd4 & fwo4_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwo4_out[0:127];
		if(fwe3_out[131] == 1 & fwe3_out[128:130] <= 3'd3 & fwe3_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwe3_out[0:127];
		if(fwo3_out[131] == 1 & fwo3_out[128:130] <= 3'd3 & fwo3_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwo3_out[0:127];
		if(fwe2_out[131] == 1 & fwe2_out[128:130] <= 3'd2 & fwe2_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwe2_out[0:127];
		if(fwo2_out[131] == 1 & fwo2_out[128:130] <= 3'd2 & fwo2_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwo2_out[0:127];
		if(fwo1_out[131] == 1 & fwo1_out[128:130] <= 3'd1 & fwo1_out[132:138] == data_rc_0[128:134]) data_out_rc_0 = fwo1_out[0:127];
		
		// Data Forwarding data_ra for odd pipe
		if(rf_wbe_out[131] == 1 & rf_wbe_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = rf_wbe_out[0:127];
		if(rf_wbo_out[131] == 1 & rf_wbo_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = rf_wbo_out[0:127];
		if(fwe7_out[131] == 1 & fwe7_out[128:130] <= 3'd7 & fwe7_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwe7_out[0:127];
		if(fwo7_out[131] == 1 & fwo7_out[128:130] <= 3'd7 & fwo7_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwo7_out[0:127];
		if(fwe6_out[131] == 1 & fwe6_out[128:130] <= 3'd6 & fwe6_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwe6_out[0:127];
		if(fwo6_out[131] == 1 & fwo6_out[128:130] <= 3'd6 & fwo6_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwo6_out[0:127];
		if(fwe5_out[131] == 1 & fwe5_out[128:130] <= 3'd5 & fwe5_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwe5_out[0:127];
		if(fwo5_out[131] == 1 & fwo5_out[128:130] <= 3'd5 & fwo5_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwo5_out[0:127];
		if(fwe4_out[131] == 1 & fwe4_out[128:130] <= 3'd4 & fwe4_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwe4_out[0:127];
		if(fwo4_out[131] == 1 & fwo4_out[128:130] <= 3'd4 & fwo4_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwo4_out[0:127];
		if(fwe3_out[131] == 1 & fwe3_out[128:130] <= 3'd3 & fwe3_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwe3_out[0:127];
		if(fwo3_out[131] == 1 & fwo3_out[128:130] <= 3'd3 & fwo3_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwo3_out[0:127];
		if(fwe2_out[131] == 1 & fwe2_out[128:130] <= 3'd2 & fwe2_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwe2_out[0:127];
		if(fwo2_out[131] == 1 & fwo2_out[128:130] <= 3'd2 & fwo2_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwo2_out[0:127];
		if(fwo1_out[131] == 1 & fwo1_out[128:130] <= 3'd1 & fwo1_out[132:138] == data_ra_1[128:134]) data_out_ra_1 = fwo1_out[0:127];
		
		// Data Forwarding data_rb for odd pipe
		if(rf_wbe_out[131] == 1 & rf_wbe_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = rf_wbe_out[0:127];
		if(rf_wbo_out[131] == 1 & rf_wbo_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = rf_wbo_out[0:127];
		if(fwe7_out[131] == 1 & fwe7_out[128:130] <= 3'd7 & fwe7_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwe7_out[0:127];
		if(fwo7_out[131] == 1 & fwo7_out[128:130] <= 3'd7 & fwo7_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwo7_out[0:127];
		if(fwe6_out[131] == 1 & fwe6_out[128:130] <= 3'd6 & fwe6_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwe6_out[0:127];
		if(fwo6_out[131] == 1 & fwo6_out[128:130] <= 3'd6 & fwo6_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwo6_out[0:127];
		if(fwe5_out[131] == 1 & fwe5_out[128:130] <= 3'd5 & fwe5_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwe5_out[0:127];
		if(fwo5_out[131] == 1 & fwo5_out[128:130] <= 3'd5 & fwo5_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwo5_out[0:127];
		if(fwe4_out[131] == 1 & fwe4_out[128:130] <= 3'd4 & fwe4_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwe4_out[0:127];
		if(fwo4_out[131] == 1 & fwo4_out[128:130] <= 3'd4 & fwo4_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwo4_out[0:127];
		if(fwe3_out[131] == 1 & fwe3_out[128:130] <= 3'd3 & fwe3_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwe3_out[0:127];
		if(fwo3_out[131] == 1 & fwo3_out[128:130] <= 3'd3 & fwo3_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwo3_out[0:127];
		if(fwe2_out[131] == 1 & fwe2_out[128:130] <= 3'd2 & fwe2_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwe2_out[0:127];
		if(fwo2_out[131] == 1 & fwo2_out[128:130] <= 3'd2 & fwo2_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwo2_out[0:127];
		if(fwo1_out[131] == 1 & fwo1_out[128:130] <= 3'd1 & fwo1_out[132:138] == data_rb_1[128:134]) data_out_rb_1 = fwo1_out[0:127];
		
		// Data Forwarding data_rc for odd pipe
		if(rf_wbe_out[131] == 1 & rf_wbe_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = rf_wbe_out[0:127];
		if(rf_wbo_out[131] == 1 & rf_wbo_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = rf_wbo_out[0:127];
		if(fwe7_out[131] == 1 & fwe7_out[128:130] <= 3'd7 & fwe7_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwe7_out[0:127];
		if(fwo7_out[131] == 1 & fwo7_out[128:130] <= 3'd7 & fwo7_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwo7_out[0:127];
		if(fwe6_out[131] == 1 & fwe6_out[128:130] <= 3'd6 & fwe6_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwe6_out[0:127];
		if(fwo6_out[131] == 1 & fwo6_out[128:130] <= 3'd6 & fwo6_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwo6_out[0:127];
		if(fwe5_out[131] == 1 & fwe5_out[128:130] <= 3'd5 & fwe5_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwe5_out[0:127];
		if(fwo5_out[131] == 1 & fwo5_out[128:130] <= 3'd5 & fwo5_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwo5_out[0:127];
		if(fwe4_out[131] == 1 & fwe4_out[128:130] <= 3'd4 & fwe4_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwe4_out[0:127];
		if(fwo4_out[131] == 1 & fwo4_out[128:130] <= 3'd4 & fwo4_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwo4_out[0:127];
		if(fwe3_out[131] == 1 & fwe3_out[128:130] <= 3'd3 & fwe3_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwe3_out[0:127];
		if(fwo3_out[131] == 1 & fwo3_out[128:130] <= 3'd3 & fwo3_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwo3_out[0:127];
		if(fwe2_out[131] == 1 & fwe2_out[128:130] <= 3'd2 & fwe2_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwe2_out[0:127];
		if(fwo2_out[131] == 1 & fwo2_out[128:130] <= 3'd2 & fwo2_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwo2_out[0:127];
		if(fwo1_out[131] == 1 & fwo1_out[128:130] <= 3'd1 & fwo1_out[132:138] == data_rc_1[128:134]) data_out_rc_1 = fwo1_out[0:127];

	end

endmodule
