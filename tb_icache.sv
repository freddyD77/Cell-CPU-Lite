module tb_icache();
    logic				clk, reset, miss;
    logic [0:31]		pc, pc2;//first 2 bits aren't used
    logic [0:31]		instr, instr2;//8 word outputs

    icache i0(.clk(clk), .reset(reset), .pc(pc), .instr(instr), .instr2(instr2), .miss(miss));


    initial clk = 0;
	

    always begin
	#1 clk = !clk;


    end
    
    initial begin
	reset = 1;
	@(posedge clk); #1;
	reset = 0;
	pc=0; pc2=4;  
	@(posedge clk); #1;
	pc=0; pc2=4;  
	@(posedge clk); #1;
	pc=0; pc2=4;  
	@(posedge clk); #1;
	pc=0; pc2=4;  
	@(posedge clk); #1;
	pc=0; pc2=4; 
	@(posedge clk); #1;
	pc=8; pc2=12;  
	@(posedge clk); #1;
	pc=8; pc2=12;  



    end

    initial begin
	#45;
	$finish;
    end

endmodule
		







