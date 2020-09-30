module tb_IF();
    logic				clk, reset;
    //logic [0:31]		pc, pc2;//first 2 bits aren't used
    logic [0:31]		instr, instr2;//8 word outputs
    logic stall;

    IF i0(.clk(clk), .reset(reset), .instr(instr), .instr2(instr2), .stall(stall), .PCBranch(0));


    initial clk = 0;
	

    always begin
	#1 clk = !clk;


    end
    
    initial begin
	reset = 1;
	stall=0;
	@(posedge clk); #1;
	reset = 0;



    end

    initial begin
	#100;
	$finish;
    end

endmodule
		







