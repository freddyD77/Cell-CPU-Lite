module tb_localstore();
    logic		clk, reset;
    //logic 		fowarded_data;
    //logic [31:0]	instructionIN, instructionOUT;
    logic [0:127]	ra, rt; 
    logic [0:138]	the_output;
    logic [0:31]	word0, word1, word2, word3, raW0, raW1, raW2, raW3, rtW0, rtW1, rtW2, rtW3, PCin;
    logic [0:15]	hw1, hw2, hw3, hw4, hw5, hw6, hw7, hw0, raHW0, raHW1, raHW2, raHW3, raHW4, raHW5, raHW6, raHW7, rtHW0, rtHW1, rtHW2, rtHW3, rtHW4, rtHW5, rtHW6, rtHW7;
    logic [0:63]	long1, long2;
    logic [7:0]		instructionNUM;
    logic [0:6]			addr_rt;
    logic [0:8]		opcode9;
    logic [0:7]		opcode8;
    logic [0:15]			immediate16;
    logic [0:9]			immediate10;
    logic			wr1;
    //logic real [31:0]		raw1short;

    localstore U0(
	.ra (ra),
	.rt (rt),
	.addr_rt (addr_rt),
	.opcode9 (opcode9),
	.opcode8 (opcode8),
	.FWpipe6 (the_output),
	.immediate10 (immediate10),
	.immediate16 (immediate16),
	.PCin (PCin),
	.reset (reset),
	.clk (clk));


    initial clk = 0;
    //initial PCin <= 0;
	

    always begin
	#5 clk = !clk;
	

	wr1 = the_output[131];

	word0 = the_output[0:31];
	word1 = the_output[32:63];
	word2 = the_output[64:95];
	word3 = the_output[96:127];
	hw0 = the_output[0:15];
	hw1 = the_output[16:31];
	hw2 = the_output[32:47];
	hw3 = the_output[48:63];
	hw4 = the_output[64:79];
	hw5 = the_output[80:95];
	hw6 = the_output[96:111];
	hw7 = the_output[112:127];
	long1 = the_output[0:63];
	long2 = the_output[64:127];

	raW0 = ra[0:31];
	raW1 = ra[32:63];
	raW2 = ra[64:95];
	raW3 = ra[96:127];

	rtW0 = rt[0:31];
	rtW1 = rt[32:63];
	rtW2 = rt[64:95];
	rtW3 = rt[96:127];


	raHW0 = ra[0:15];
	raHW1 = ra[16:31];
	raHW2 = ra[32:47];
	raHW3 = ra[48:63];
	raHW4 = ra[64:79];
	raHW5 = ra[80:95];
	raHW6 = ra[96:111];
	raHW7 = ra[112:127];

	rtHW0 = rt[0:15];
	rtHW1 = rt[16:31];
	rtHW2 = rt[32:47];
	rtHW3 = rt[48:63];
	rtHW4 = rt[64:79];
	rtHW5 = rt[80:95];
	rtHW6 = rt[96:111];
	rtHW7 = rt[112:127];

    end

    always_ff @(posedge clk) begin
    	if(reset)
    		PCin <= 0;
    	else
    		PCin <= PCin + 32;
    end
    
    initial begin
	
	ra[0:31] = 	32'b00110111001001111100010110101100;//10.0_e-5;
	ra[32:63] = 	32'b01100001001011010111100011101100;//2.0_e20;
	ra[64:95] = 	32'b01010000000101010000001011111001;//1.0_e10;
	ra[96:127] = 0;

	rt[0:31] = 	32'b00011111011011000001111001001010;//5.0e-20;
	rt[32:63] = 	32'b00001110001101000100010100100010;//2.222e-30;
	rt[64:95] = 	32'b00100100000010100101100111000000;//-3.0e-17;
	rt[96:127] = 	32'b11000110110000110101000000000000;//-2.5e4;

	

	reset = 1;
	@(posedge clk); #1;
	

	@(posedge clk); #1; reset = 0;
	instructionNUM = 0; immediate16=0; opcode8=0;
	opcode9=9'b001100001; addr_rt=0; immediate10=0;//load quad word A-form
	@(posedge clk); #1;
	instructionNUM = 1; immediate16=1; opcode8=0;
	opcode9=9'b001100111; addr_rt=1; immediate10=1;//load quad word instruction relative A-form
	@(posedge clk); #1;
	instructionNUM = 2; immediate16=2; opcode8=0;
	opcode9=9'b001000001; addr_rt=2; immediate10=2;//store quad word A-form
	@(posedge clk); #1;
	instructionNUM = 3; immediate16=3; opcode8=0;
	opcode9=9'b001000111; addr_rt=3; immediate10=3;//store quad word instruction relative A-form
	@(posedge clk); #1;
	instructionNUM = 4; immediate16=4; opcode9=0;
	opcode8=8'b00110100; addr_rt=4; immediate10=4;//load quad word D-form
	@(posedge clk); #1;
	instructionNUM = 5; immediate16=5; opcode9=0;
	opcode8=8'b00100100; addr_rt=5; immediate10=5;//store quad word D-form



    end

    initial begin
	#250;
	$finish;
    end

endmodule
		







