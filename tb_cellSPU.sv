module tb_cellSPU();
    logic				clk, reset;

    cellSPU c0(.clk(clk), .reset(reset));


    initial clk = 0;
	

    always begin
	#1 clk = !clk;


    end
    
    initial begin
	reset = 1;
	@(posedge clk); #1;
	reset = 0;
    end

    initial begin
	#20000;
	$finish;
    end

endmodule
		







