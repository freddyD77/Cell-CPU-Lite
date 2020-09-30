module tb_processing();

	logic						clk, reset;
	logic		 [0:31] 		instructionEven, instructionOdd, PCin;
	logic [0:32]			PCOut;

	logic	[0:134]		data_ra_0, data_rb_0, data_rc_0, data_ra_1, data_rb_1, data_rc_1;
	logic	[0:138]		fwe2_out, fwe3_out, fwe4_out, fwe5_out, fwe6_out, fwe7_out, rf_wbe_out;
	logic	[0:138]		fwo1_out, fwo2_out, fwo3_out, fwo4_out, fwo5_out, fwo6_out, fwo7_out, rf_wbo_out;
	logic	[0:127]		data_out_ra_0, data_out_rb_0, data_out_rc_0, data_out_ra_1, data_out_rb_1, data_out_rc_1;

	logic [0:6]			fwo1_addr, fwo2_addr, fwo3_addr, fwo4_addr, fwo5_addr, fwo6_addr, fwo7_addr, rf_wbo_addr,
						fwe2_addr, fwe3_addr, fwe4_addr, fwe5_addr, fwe6_addr, fwe7_addr, rf_wbe_addr,
						data_ra_0_addr, data_rb_0_addr, data_rc_0_addr, data_ra_1_addr, data_rb_1_addr, data_rc_1_addr,

						ra0, rb0, rc0, rt0, ra1, rb1, rc1, rt1;
	logic [0:10]		opcode0, opcode1;





	ProcessingUnit P0(
	.data_rc_1 (data_rc_1),
	.data_rb_1 (data_rb_1),
	.data_ra_1 (data_ra_1),
	.data_rc_0 (data_rc_0),
	.data_rb_0 (data_rb_0),
	.data_ra_0 (data_ra_0),
	.fwe7_out (fwe7_out),
	.fwe6_out (fwe6_out),
	.fwe5_out (fwe5_out),
	.fwe4_out (fwe4_out),
	.fwe3_out (fwe3_out),
	.fwe2_out (fwe2_out),
	.fwo7_out (fwo7_out),
	.fwo6_out (fwo6_out),
	.fwo5_out (fwo5_out),
	.fwo4_out (fwo4_out),
	.fwo3_out (fwo3_out),
	.fwo2_out (fwo2_out),
	.fwo1_out (fwo1_out),
	.data_out_rc_1 (data_out_rc_1),
	.data_out_rb_1 (data_out_rb_1),
	.data_out_ra_1 (data_out_ra_1),
	.data_out_rc_0 (data_out_rc_0),
	.data_out_rb_0 (data_out_rb_0),
	.data_out_ra_0 (data_out_ra_0), 
	.instructionOdd (instructionOdd),
	.instructionEven (instructionEven),
	.PCin (PCin),
	.reset (reset),
	.clk (clk));

	initial clk = 0;
	initial PCin = 0;
	

    always begin
	#1 clk = !clk;
	#1 PCin = PCin + 4;

	fwo1_addr = fwo1_out[132:138];
	fwo2_addr = fwo2_out[132:138];
	fwo3_addr = fwo3_out[132:138];
	fwo4_addr = fwo4_out[132:138];
	fwo5_addr = fwo5_out[132:138];
	fwo6_addr = fwo6_out[132:138];
	fwo7_addr = fwo7_out[132:138];
	rf_wbo_addr = rf_wbo_out[132:138];

	fwe2_addr = fwe2_out[132:138];
	fwe3_addr = fwe3_out[132:138];
	fwe4_addr = fwe4_out[132:138];
	fwe5_addr = fwe5_out[132:138];
	fwe6_addr = fwe6_out[132:138];
	fwe7_addr = fwe7_out[132:138];
	rf_wbe_addr = rf_wbe_out[132:138];

	data_ra_0_addr = data_ra_0[128:134];
	data_rb_0_addr = data_rb_0[128:134];
	data_rc_0_addr = data_rc_0[128:134];
	data_ra_1_addr = data_ra_1[128:134];
	data_rb_1_addr = data_rb_1[128:134];
	data_rc_1_addr = data_rc_1[128:134];

	end

	initial begin

	reset = 1;
	@(posedge clk); #1;
	reset = 0;
	@(posedge clk); #1;//add half word //gather bits from bytes
	opcode0=11'b00011001000; opcode1=11'b00110110010; 
	ra0=1; rb0=2; rc0=3; rt0=4; ra1=5; rb1=6; rc1=7; rt1=8;
	instructionEven={opcode0, rb0, ra0, rt0};		instructionOdd={opcode1, 7'd0, ra1, rt1};
	@(posedge clk); #1;//add halfword imm //gather bits from words
	opcode0=11'b00011101000; opcode1=11'b01111000000; 
	ra0=9; rb0=10; rc0=11; rt0=12; ra1=13; rb1=14; rc1=15; rt1=16;
	instructionEven={opcode0[0:7], 10'd5, ra0, rt0};		instructionOdd={opcode1, 7'd0, ra1, rt1};
	@(posedge clk); #1;//multiply //branch relative
	opcode0=11'b01111000100; opcode1=11'b00110010000; 
	ra0=17; rb0=18; rc0=19; rt0=20; ra1=21; rb1=22; rc1=23; rt1=24;
	instructionEven={opcode0, rb0, ra0, rt0};		instructionOdd={opcode1[0:8], 16'd100, 7'd0};
	@(posedge clk); #1;//multiply unsigned //branch relative and setlink
	opcode0=11'b01111001100; opcode1=11'b00110011000; 
	ra0=25; rb0=26; rc0=27; rt0=28; ra1=29; rb1=30; rc1=31; rt1=32;
	instructionEven={opcode0, rb0, ra0, rt0};		instructionOdd={opcode1[0:8], 16'd200, rt1};
	@(posedge clk); #1;//shiftleft halfword //shiftleft quadword by bytes
	opcode0=11'b00001011111; opcode1=11'b00111011111; 
	ra0=33; rb0=34; rc0=35; rt0=36; ra1=37; rb1=38; rc1=39; rt1=40;
	instructionEven={opcode0, rb0, ra0, rt0};		instructionOdd={opcode1, rb1, ra1, rt1};
	@(posedge clk); #1;//shiftleft halfword imm //shiftleft quadword by bytes imm
	opcode0=11'b00001111111; opcode1=11'b00111011111; 
	ra0=41; rb0=42; rc0=43; rt0=44; ra1=45; rb1=46; rc1=47; rt1=48;
	instructionEven={opcode0, 7'd6, ra0, rt0};		instructionOdd={opcode1, 7'd6, ra1, rt1};
	@(posedge clk); #1;//average bytes //branch if zero word
	opcode0=11'b00011010011; opcode1=11'b00100000000; 
	ra0=49; rb0=50; rc0=51; rt0=52; ra1=53; rb1=54; rc1=55; rt1=56;
	instructionEven={opcode0, rb0, ra0, rt0};		instructionOdd={opcode1[0:8], 16'd300, rt1};
	@(posedge clk); #1;//absolute difference of bytes //branch if not zero word
	opcode0=11'b00110110010; opcode1=11'b00100001000; 
	ra0=57; rb0=58; rc0=59; rt0=60; ra1=61; rb1=62; rc1=63; rt1=64;
	instructionEven={opcode0, rb0, ra0, rt0};		instructionOdd={opcode1[0:8], 16'd400, rt1};



    end

    initial begin
	#60;
	$finish;
    end


endmodule
