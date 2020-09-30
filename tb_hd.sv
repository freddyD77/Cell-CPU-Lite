module tb_hd();
    logic				clk, reset, miss1, miss2, validPCs, validPCs2;
    logic [0:31]		missedPC, missedPC2;//first 2 bits aren't used
    logic [0:2][0:31]	instr8, instr8_2;//8 word outputs

    hardDisk h0(.clk(clk), .reset(reset), .missedPC(missedPC), .missedPC2(missedPC2), 
    	.miss1(miss1), .miss2(miss2), .instr8(instr8), .instr8_2(instr8_2), .valid1(validPCs), .valid2(validPCs2));


    initial clk = 0;
	

    always begin
	#1 clk = !clk;


    end
    
    initial begin
	reset = 1;
	@(posedge clk); #1;
	reset = 0;
	miss1=0; miss2=0; missedPC=0; missedPC2=2;
	@(posedge clk); #1;
	miss1=1; miss2=1; missedPC=1; missedPC2=2;
	@(posedge clk); #1;
	miss1=1; miss2=1; missedPC=1; missedPC2=2;
	@(posedge clk); #1;
	miss1=1; miss2=1; missedPC=1; missedPC2=2;
	@(posedge clk); #1;
	miss1=1; miss2=1; missedPC=1; missedPC2=2;
	@(posedge clk); #1;
	miss1=1; miss2=0; missedPC=1; missedPC2=0;
	@(posedge clk); #1;
	miss1=0; miss2=0; missedPC=0; missedPC2=0;



    end

    initial begin
	#45;
	$finish;
    end

endmodule
		







