module tb_branch();
    logic		clk, reset;
    //logic 		fowarded_data;
    //logic [31:0]	instructionIN, instructionOUT;
    logic [0:127]	rt; 
    logic [0:138]	the_output;
    logic [0:31]	word0, word1, word2, word3, rtW0, rtW1, rtW2, rtW3, PCin;
    logic [0:15]	hw1, hw2, hw3, hw4, hw5, hw6, hw7, hw0, rtHW0, rtHW1, rtHW2, rtHW3, rtHW4, rtHW5, rtHW6, rtHW7;
    logic [0:63]	long1, long2;
    logic [7:0]		instructionNUM;
    logic [0:6]			addr_rt;
    logic [0:8]		opcode9;
    logic [0:15]			immediate16;
    logic			wr;
    logic [0:32]	PCout;
    //logic real [31:0]		rtw1short;

    branch U0(
	.rt (rt),
	.addr_rt (addr_rt),
	.opcode9 (opcode9),
	.pipe (the_output),
	.immediate16 (immediate16),
	.reset (reset),
	.clk (clk),
	.PCpipe (PCout),
	.PCin (PCin));


    initial clk = 0;
	

    always begin
	
    #1 clk = !clk;

	wr = the_output[131];

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

	rtW0 = rt[0:31];
	rtW1 = rt[32:63];
	rtW2 = rt[64:95];
	rtW3 = rt[96:127];


	rtHW0 = rt[0:15];
	rtHW1 = rt[16:31];
	rtHW2 = rt[32:47];
	rtHW3 = rt[48:63];
	rtHW4 = rt[64:79];
	rtHW5 = rt[80:95];
	rtHW6 = rt[96:111];
	rtHW7 = rt[112:127];


	
    end
    
    initial begin
	
	rt[0:31] = 	32'b00110111001001111100010110101100;//10.0_e-5;
	rt[32:63] = 	32'b01100001001011010111100011101100;//2.0_e20;
	rt[64:95] = 	32'b01010000000101010000001011111001;//1.0_e10;
	rt[96:127] = 0;


	reset = 1;
	@(posedge clk); #1;
	reset = 0; PCin = 0;

	@(posedge clk); #1;
	instructionNUM = 0; PCin = 4;
	opcode9=9'b001100100; addr_rt=0; immediate16=1;//branch relative

	@(posedge clk); #1;
	instructionNUM = 1; PCin = 8;
	opcode9=9'b001100110; addr_rt=1; immediate16=2;//branch relative and set link

	@(posedge clk); #1;
	instructionNUM = 2; PCin = 12;
	opcode9=9'b001000000; addr_rt=2; immediate16=3;//branch if word zero

	@(posedge clk); #1;
	instructionNUM = 3; PCin = 16;
	opcode9=9'b001000010; addr_rt=3; immediate16=4;//branch if word not zero



    end

    initial begin
	#15;
	$finish;
    end

endmodule
		







