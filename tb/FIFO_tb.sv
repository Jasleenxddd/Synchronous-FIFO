import FIFO_shared_pkg::*;
import FIFO_transaction_pkg::*;

module FIFO_tb (FIFO_if.TEST F_if);
FIFO_transaction object;

initial begin
	object = new();
	F_if.data_in = 0;
	F_if.wr_en = 0;
	F_if.rd_en = 0;
	F_if.rst_n = 0;
	@(negedge F_if.clk);#0;
	F_if.rst_n = 1;
	repeat(10000) begin
		assert(object.randomize());
		F_if.rst_n = object.rst_n;
		F_if.data_in = object.data_in;
		F_if.wr_en = object.wr_en;
		F_if.rd_en = object.rd_en;
		@(negedge F_if.clk);#0;
	end
	test_finished = 1;
       
    
end

endmodule : FIFO_tb

