/* Even Pipe module containing SimpleFixed1, SimpleFixed2, Byte and Single Precision units
 * It also hosts all the forwarding registers through which the outputs from the units are shifted.
*/
module EvenPipe(
  input						clk, reset, flush,
  input	 		[0:127]		data_ra, data_rb, data_rc,
  input  		[0:17]		immediate,
  input  		[0:6]		addr_rt,
  input  		[0:10]		opcode,		
  output logic 	[0:138]		fwe2_out, fwe3_out, fwe4_out, fwe5_out, fwe6_out, fwe7_out, rf_wbe_out);

  logic [0:138]	sp2_out, b1_out,fp1_out, fp2_out, fwe3_reg, fwe6_reg, fwe7_reg;

  SimpleFixed1 sp1(.clk(clk), .reset(reset), .data_ra(data_ra), .data_rb(data_rb), .immediate(immediate), .addr_rt(addr_rt), .opcode(opcode), .flush(flush)
					, .out_data(fwe2_out));
  SimpleFixed2 sp2(.clk(clk), .reset(reset), .data_ra(data_ra), .data_rb(data_rb), .immediate(immediate[4:10]), .addr_rt(addr_rt), .flush(flush)
					, .opcode(opcode), .out_data(sp2_out));
  Byte b1(.clk(clk), .reset(reset), .data_ra(data_ra), .data_rb(data_rb), .addr_rt(addr_rt), .opcode(opcode), .flush(flush), .out_data(b1_out));
  singlePrec fp1(.clk(clk), .reset(reset), .ra(data_ra), .rb(data_rb), .rc(data_rc), .opcode11(opcode), .opcode10(opcode[0:9]), .opcode8(opcode[0:7])
					, .opcode4(opcode[0:3]), .immediate10(immediate[1:10]), .immediate8(immediate[3:10]), .pipe6out(fp1_out), .pipe7out(fp2_out), .addr_rt(addr_rt)
					, .flush(flush));
  
  always_ff @(posedge clk) begin

	fwe3_reg <= fwe2_out;
	fwe4_out <= fwe3_out;
	fwe5_out <= fwe4_out;
	fwe6_reg <= fwe5_out;
	fwe7_reg <= fwe6_out;
	rf_wbe_out <= fwe7_out;

  end

  always_comb begin
	
	if(sp2_out[131] == 1'b1) fwe3_out = sp2_out;
	else if(b1_out[131] == 1'b1) fwe3_out = b1_out;
	else fwe3_out = fwe3_reg;
	
	if(fp1_out[131] == 1'b1) fwe6_out = fp1_out;
	else fwe6_out = fwe6_reg;

	if(fp2_out[131] == 1'b1) fwe7_out = fp2_out;
	else fwe7_out = fwe7_reg;
	
  end

endmodule
