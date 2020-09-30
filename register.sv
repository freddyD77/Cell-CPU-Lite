/* Module for register file:
 * 128 registers each of 128 bits width
 * Total 6 read ports to read operands and 2 write ports to write data each cycle.
 * If the read address on any of the read ports is same as the write address in the same cycle then the input data is forwarded to the output bus thereby simulating
 * the ability to read and write from a location in the same cycle.
 */
module registerFile(
  input					clk, reset, wr_en_0, wr_en_1,
  input  [0:6]			addr_ra_0, addr_rb_0, addr_rc_0,
  input  [0:6]			addr_ra_1, addr_rb_1, addr_rc_1,
  input  [0:6]			wr_addr_0, wr_addr_1,
  input  [0:127]		wr_data_0, wr_data_1,
  output reg [0:134]	data_ra_0, data_rb_0, data_rc_0,
  output reg [0:134]	data_ra_1, data_rb_1, data_rc_1);

  logic [0:127] [0:127] mem;
  int i;

  always_ff @(posedge clk) begin

	// Reading data for the even pipe and appending source register addresses for data forwarding
	data_ra_0[0:127] <= (wr_en_0 & (addr_ra_0 == wr_addr_0)) ? wr_data_0 : ((wr_en_1 & (addr_ra_0 == wr_addr_1)) ? wr_data_1 : mem[addr_ra_0]);
	data_ra_0[128:134] <= addr_ra_0;
	data_rb_0[0:127] <= (wr_en_0 & (addr_rb_0 == wr_addr_0)) ? wr_data_0 : ((wr_en_1 & (addr_rb_0 == wr_addr_1)) ? wr_data_1 : mem[addr_rb_0]);
	data_rb_0[128:134] <= addr_rb_0;
	data_rc_0[0:127] <= (wr_en_0 & (addr_rc_0 == wr_addr_0)) ? wr_data_0 : ((wr_en_1 & (addr_rc_0 == wr_addr_1)) ? wr_data_1 : mem[addr_rc_0]);
	data_rc_0[128:134] <= addr_rc_0;
	
	// Reading data for the odd pipe and appending source register addresses for data forwarding
	data_ra_1[0:127] <= (wr_en_0 & (addr_ra_1 == wr_addr_0)) ? wr_data_0 : ((wr_en_1 & (addr_ra_1 == wr_addr_1)) ? wr_data_1 : mem[addr_ra_1]);
	data_ra_1[128:134] <= addr_ra_1;
	data_rb_1[0:127] <= (wr_en_0 & (addr_rb_1 == wr_addr_0)) ? wr_data_0 : ((wr_en_1 & (addr_rb_1 == wr_addr_1)) ? wr_data_1 : mem[addr_rb_1]);
	data_rb_1[128:134] <= addr_rb_1;
	data_rc_1[0:127] <= (wr_en_0 & (addr_rc_1 == wr_addr_0)) ? wr_data_0 : ((wr_en_1 & (addr_rc_1 == wr_addr_1)) ? wr_data_1 : mem[addr_rc_1]);
	data_rc_1[128:134] <= addr_rc_1;
	
	// Writing data from the even pipe
	if(wr_en_0)
	  mem[wr_addr_0] <= wr_data_0;

	// Writing data from odd pipe
	if(wr_en_1)
	  mem[wr_addr_1] <= wr_data_1;

	if(reset) begin
		for (i=0; i<128; i=i+1) begin
			mem[i] <= 0;
		end
	end  
	

  end

endmodule
