/* Top Processing Unit module for Cell-SPU-Lite */
module ProcessingUnit(
	input						clk, reset, flush, predictIn,
	input		 [0:34] 		instructionEven, instructionOdd, 
	input		 [0:31]			PCin, predictPCin,
	output logic [0:65]			PCout);
	
	logic	[0:134]		data_ra_0, data_rb_0, data_rc_0, data_ra_1, data_rb_1, data_rc_1;
	logic	[0:138]		fwe2_out, fwe3_out, fwe4_out, fwe5_out, fwe6_out, fwe7_out, rf_wbe_out;
	logic	[0:138]		fwo1_out, fwo2_out, fwo3_out, fwo4_out, fwo5_out, fwo6_out, fwo7_out, rf_wbo_out;
	logic	[0:127]		data_out_ra_0, data_out_rb_0, data_out_rc_0, data_out_ra_1, data_out_rb_1, data_out_rc_1;//);
	logic	[0:10]		opcode_0, opcode_1, opcode_reg_0, opcode_reg_1;
	logic	[0:17]		immediate_reg_0, immediate_reg_1;
	logic	[0:6]		addr_rt_0, addr_rt_reg_0, addr_rt_reg_1;
	logic				reset_reg;
	logic	[0:31]		PC_in_reg, predictPCin_reg, predictPCin_reg_1;
	logic				flushInstr, flush_reg, flush_reg_1, predictIn_reg, predictIn_reg_1;
	
	registerFile rf(.clk(clk), .reset(reset), .wr_en_0(rf_wbe_out[131]), .wr_en_1(rf_wbo_out[131]), .addr_rb_0(instructionEven[11:17]), .addr_ra_0(instructionEven[18:24]), 
					.addr_rc_0(instructionEven[25:31]), .addr_rb_1(instructionOdd[11:17]), .addr_ra_1(instructionOdd[18:24]), .addr_rc_1(instructionOdd[25:31]),
					.wr_addr_0(rf_wbe_out[132:138]), .wr_addr_1(rf_wbo_out[132:138]), .wr_data_0(rf_wbe_out[0:127]), .wr_data_1(rf_wbo_out[0:127]),
					.data_ra_0(data_ra_0), .data_rb_0(data_rb_0), .data_rc_0(data_rc_0), .data_ra_1(data_ra_1), .data_rb_1(data_rb_1), .data_rc_1(data_rc_1));
	
	DataForward df(.data_ra_0(data_ra_0), .data_rb_0(data_rb_0), .data_rc_0(data_rc_0), .data_ra_1(data_ra_1), .data_rb_1(data_rb_1), .data_rc_1(data_rc_1),
				   .fwe2_out(fwe2_out), .fwe3_out(fwe3_out), .fwe4_out(fwe4_out), .fwe5_out(fwe5_out), .fwe6_out(fwe6_out), .fwe7_out(fwe7_out),
				   .rf_wbe_out(rf_wbe_out), .fwo1_out(fwo1_out), .fwo2_out(fwo2_out), .fwo3_out(fwo3_out), .fwo4_out(fwo4_out), .fwo5_out(fwo5_out),
				   .fwo6_out(fwo6_out), .fwo7_out(fwo7_out), .rf_wbo_out(rf_wbo_out), .data_out_ra_0(data_out_ra_0), .data_out_rb_0(data_out_rb_0),
				   .data_out_rc_0(data_out_rc_0), .data_out_ra_1(data_out_ra_1), .data_out_rb_1(data_out_rb_1), .data_out_rc_1(data_out_rc_1));
	
	EvenPipe ep(.clk(clk), .reset(reset_reg), .data_ra(data_out_ra_0), .data_rb(data_out_rb_0), .data_rc(data_out_rc_0), .immediate(immediate_reg_0),.opcode(opcode_0),
				.addr_rt(addr_rt_reg_0), .fwe2_out(fwe2_out), .fwe3_out(fwe3_out), .fwe4_out(fwe4_out), .fwe5_out(fwe5_out), .fwe6_out(fwe6_out),
				.fwe7_out(fwe7_out), .rf_wbe_out(rf_wbe_out), .flush(flushInstr));
	
	oddPipe op(.clk(clk), .reset(reset_reg), .data_ra(data_out_ra_1), .data_rb(data_out_rb_1), .data_rc(data_out_rc_1), .immediate(immediate_reg_1), .opcode(opcode_1), 
			   .addr_rt(addr_rt_reg_1), .PCin(PC_in_reg), .fwo1_out(fwo1_out), .fwo2_out(fwo2_out), .fwo3_out(fwo3_out), .fwo4_out(fwo4_out), .fwo5_out(fwo5_out),
			   .fwo6_out(fwo6_out), .fwo7_out(fwo7_out), .rf_wbo_out(rf_wbo_out), .PCout(PCout), .predictIn(predictIn_reg), .predictPCin(predictPCin_reg));
	
	always_ff @(posedge clk) begin

		reset_reg <= reset;
		PC_in_reg <= PCin;
		predictPCin_reg <= predictPCin;
		predictPCin_reg_1 <= predictPCin_reg;
		predictIn_reg <= predictIn;
		predictIn_reg_1 <= predictIn_reg;
		flush_reg <= flush;
		flush_reg_1 <= flush_reg;

		if(reset_reg | PCout[65]) begin

			opcode_reg_0 <= 11'b01000000001;
			addr_rt_reg_0 <= 0;
			immediate_reg_0 <= 0;
		
			opcode_reg_1 <= 11'b00000000001;
			addr_rt_reg_1 <= 0;
			immediate_reg_1 <= 0;

		end else begin

		
			opcode_reg_0 <= instructionEven[0:10];
			addr_rt_reg_0 <= addr_rt_0;
			immediate_reg_0 <= instructionEven[7:24];
			
			opcode_reg_1 <= instructionOdd[0:10];
			addr_rt_reg_1 <= instructionOdd[25:31];
			immediate_reg_1 <= instructionOdd[7:24];

		end

	end

	always_comb begin
		
		addr_rt_0 = (instructionEven[0:3] == 4'b1100 | instructionEven[0:3] == 4'b1110 | instructionEven[0:3] == 4'b1111) 
					? instructionEven[4:10] : instructionEven[25:31];
		flushInstr = flush_reg_1 & PCout[32];
		opcode_0 = (PCout[65]) ? 11'b0100_0000_001 : opcode_reg_0;
		opcode_1 = (PCout[65]) ? 11'b0000_0000_001 : opcode_reg_1;
	end
	
endmodule
