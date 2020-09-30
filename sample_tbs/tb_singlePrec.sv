module tb_singlePrec();
    logic		clk;
    logic 		reset;
    logic [0:127]	ra, rb, rc; 
    logic [0:138]	the_output6, the_output7;
    logic [0:31]	word1, word2, word3, word0, raW0, raW1, raW2, raW3, rbW0, rbW1, rbW2, rbW3, rcW0, rcW1, rcW2, rcW3;
    logic [0:15]	hw1, hw2, hw3, hw4, hw5, hw6, hw7, hw0, raHW0, raHW1, raHW2, raHW3, raHW4, raHW5, raHW6, raHW7, rbHW0, rbHW1, rbHW2, rbHW3, rbHW4, rbHW5, rbHW6, rbHW7,
			rcHW0, rcHW1, rcHW2, rcHW3, rcHW4, rcHW5, rcHW6, rcHW7;
    logic [0:63]	long1, long2;
    logic [0:7]		instructionNUM;
    logic [0:10]		opcode11;
    logic [0:9]			opcode10;
    logic [0:7]			opcode8;
    logic [0:3]			opcode4;
    logic [0:9]			immediate10;
    logic [0:7]			immediate8;
    logic [0:6]			addr_rt;
    //logic real [31:0]		raw1short;
    logic 				wr;

    singlePrec U0(
	.ra (ra),
	.rb (rb),
	.rc (rc),
	.clk (clk),
	.addr_rt (addr_rt),
	.reset (reset),
	.opcode11 (opcode11),
	.opcode10 (opcode10),
	.opcode8 (opcode8),
	.opcode4 (opcode4),
	.immediate10 (immediate10),
	.immediate8 (immediate8),
	.pipe6out (the_output6),
	.pipe7out (the_output7));

    initial clk = 0;
	

    always begin
	#1 clk = !clk;

	wr = the_output6[131];

	word0 = the_output6[0:31];
	word1 = the_output6[32:63];
	word2 = the_output6[64:95];
	word3 = the_output6[96:127];
	hw0 = the_output6[0:15];
	hw1 = the_output6[16:31];
	hw2 = the_output6[32:47];
	hw3 = the_output6[48:63];
	hw4 = the_output6[64:79];
	hw5 = the_output6[80:95];
	hw6 = the_output6[96:111];
	hw7 = the_output6[112:127];
	long1 = the_output6[0:63];
	long2 = the_output6[64:127];

	raW0 = ra[0:31];
	raW1 = ra[32:63];
	raW2 = ra[64:95];
	raW3 = ra[96:127];

	rbW0 = rb[0:31];
	rbW1 = rb[32:63];
	rbW2 = rb[64:95];
	rbW3 = rb[96:127];

	rcW0 = rc[0:31];
	rcW1 = rc[32:63];
	rcW2 = rc[64:95];
	rcW3 = rc[96:127];

	raHW0 = ra[0:15];
	raHW1 = ra[16:31];
	raHW2 = ra[32:47];
	raHW3 = ra[48:63];
	raHW4 = ra[64:79];
	raHW5 = ra[80:95];
	raHW6 = ra[96:111];
	raHW7 = ra[112:127];

	rbHW0 = rb[0:15];
	rbHW1 = rb[16:31];
	rbHW2 = rb[32:47];
	rbHW3 = rb[48:63];
	rbHW4 = rb[64:79];
	rbHW5 = rb[80:95];
	rbHW6 = rb[96:111];
	rbHW7 = rb[112:127];

	rcHW0 = rc[0:15];
	rcHW1 = rc[16:31];
	rcHW2 = rc[32:47];
	rcHW3 = rc[48:63];
	rcHW4 = rc[64:79];
	rcHW5 = rc[80:95];
	rcHW6 = rc[96:111];
	rcHW7 = rc[112:127];

    end
    
    initial begin
	
	

	ra[0:31] = 	32'b00110111001001111100010110101100;//10.0_e-5;
	ra[32:63] = 	32'b01100001001011010111100011101100;//2.0_e20;
	ra[64:95] = 	32'b01010000000101010000001011111001;//1.0_e10;
	ra[96:127] = 0;

	rb[0:31] = 	32'b00011111011011000001111001001010;//5.0e-20;
	rb[32:63] = 	32'b00001110001101000100010100100010;//2.222e-30;
	rb[64:95] = 	32'b00100100000010100101100111000000;//-3.0e-17;
	rb[96:127] = 	32'b11000110110000110101000000000000;//-2.5e4;

	rc[0:31] = 0;
	rc[32:63] = 0;
	rc[64:95] = 0;
	rc[96:127] = 0;

	reset=1;
	@(posedge clk); #1;
	reset=0;
	@(posedge clk); #1;
	instructionNUM = 0; immediate10=0; immediate8=0;
	opcode11=11'b01111000100; opcode10=0; opcode8=0; opcode4=0; addr_rt=0;//multiply						good
	@(posedge clk); #1;
	instructionNUM = 1; immediate10=1; immediate8=1;
	opcode11=11'b01111001100; opcode10=0; opcode8=0; opcode4=0; addr_rt=1;//multiply unsigned				good
	@(posedge clk); #1;
	instructionNUM = 2; immediate10=2; immediate8=2;
	opcode11=11'b01111000101; opcode10=0; opcode8=0; opcode4=0; addr_rt=2;//multiply	high					good
	/*@(posedge clk); #1;
	instructionNUM = 3;
	instructionIN = 32'b01011000100000000000000000000000;//floating add					good ish	
	@(posedge clk); #1;
	instructionNUM = 4;
	instructionIN = 32'b01011000101000000000000000000000;//floating subtract				good ish
	@(posedge clk); #1;
	instructionNUM = 5;
	instructionIN = 32'b01011000110000000000000000000000;//floating multiply				bad
	@(posedge clk); #1;
	instructionNUM = 6;
	instructionIN = 32'b01111000010000000000000000000000;//floating compare equal				bad
	@(posedge clk); #1;
	instructionNUM = 7;
	instructionIN = 32'b01111001010000000000000000000000;//floating compare equal magnitude			bad
	@(posedge clk); #1;
	instructionNUM = 8;
	instructionIN = 32'b01011000010000000000000000000000;//floating compare greater than			bad
	@(posedge clk); #1;
	instructionNUM = 9;
	instructionIN = 32'b01011001010000000000000000000000;//floating compare magnitude greater than		bad
	@(posedge clk); #1;
	instructionNUM = 10;
	instructionIN = 32'b01110110100000000000000000000000;//Convert Signed Integer to Floating		bad
	@(posedge clk); #1;
	instructionNUM = 11;
	instructionIN = 32'b01110110000000000000000000000000;//Convert Floating to Signed Integer		bad	
	@(posedge clk); #1;
	instructionNUM = 12;
	instructionIN = 32'b01110110110000000000000000000000;//Convert Unsigned Integer to Floating		bad
	@(posedge clk); #1;
	instructionNUM = 13;
	instructionIN = 32'b01110110010000000000000000000000;//Convert Floating to Unsigned Integer		bad*/
	@(posedge clk); #1;
	instructionNUM = 14; immediate10=3; immediate8=3;
	opcode11=0; opcode10=0; opcode8=8'b01110100; opcode4=0; addr_rt=3;//multiply immediate				good	
	@(posedge clk); #1;
	instructionNUM = 15; immediate10=4; immediate8=4;
	opcode11=0; opcode10=0; opcode8=0; opcode4=4'b1100; addr_rt=4;//multiply add					good	
	/*@(posedge clk); #1;
	instructionNUM = 16;
	instructionIN = 32'b11100000000000000000000000000000;//floating multiply add				bad
	@(posedge clk); #1;
	instructionNUM = 17;
	instructionIN = 32'b11110000000000000000000000000000;//floating multiply subtract			bad*/			


    end

    initial begin
	#36;
	$finish;
    end

endmodule
		







