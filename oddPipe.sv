
/* Odd Pipe contains the branch, local store, and permute units.
 * It also hosts all the forwarding registers through which the outputs from the units are shifted.
*/
module oddPipe(
  input						clk, reset, predictIn,
  input	 		[0:127]		data_ra, data_rb, data_rc,
  input  		[0:17]		immediate,
  input  		[0:6]		addr_rt,
  input  		[0:10]		opcode,
  input			[0:31]		PCin, predictPCin,
  output logic	[0:65]		PCout,
  output logic 	[0:138]		fwo1_out, fwo2_out, fwo3_out, fwo4_out, fwo5_out, fwo6_out, fwo7_out, rf_wbo_out);

  logic [0:138]	perm_out, LS_out, br_out, fwo3_reg, fwo6_reg;

  permute perm(.clk(clk), .reset(reset), .ra(data_ra), .rb(data_rb), .opcode11(opcode), .immediate7(immediate[4:10]), .WBpipe3(perm_out)
		, .addr_rt(addr_rt));  

  localstore LS(.clk(clk), .reset(reset), .ra(data_ra), .rt(data_rc), .opcode9(opcode[0:8]), .opcode8(opcode[0:7])
		, .immediate16(immediate[2:17]), .immediate10(immediate[1:10]), .FWpipe6(LS_out)
		, .addr_rt(addr_rt), .PCin(PCin));

  branch br(.clk(clk), .reset(reset), .addr_rt(addr_rt), .opcode9(opcode[0:8]), .immediate16(immediate[2:17]) 
		, .pipe(br_out), .PCpipe(PCout), .PCin(PCin), .predictPCin(predictPCin), .predictIn(predictIn), .rt(data_rc)); 

  
  always_ff @(posedge clk) begin

	fwo2_out <= fwo1_out;
	fwo3_reg <= fwo2_out;
	fwo4_out <= fwo3_out;
	fwo5_out <= fwo4_out;
	fwo6_reg <= fwo5_out;
	fwo7_out <= fwo6_out;
	rf_wbo_out <= fwo7_out;

  end

  always_comb begin
	
	fwo1_out = br_out;	

	if(perm_out[131] == 1'b1) fwo3_out = perm_out;
	else fwo3_out = fwo3_reg;

	if(LS_out[131] == 1'b1) fwo6_out = LS_out;
	else fwo6_out = fwo6_reg;
	
  end

endmodule
