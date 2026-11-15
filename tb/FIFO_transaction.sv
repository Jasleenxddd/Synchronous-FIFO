package FIFO_transaction_pkg;
	class FIFO_transaction;
		parameter FIFO_WIDTH = 16;
		parameter FIFO_DEPTH = 8;
		rand logic [FIFO_WIDTH-1:0] data_in;
		rand logic rst_n, wr_en, rd_en;
		logic [FIFO_WIDTH-1:0] data_out;
		logic wr_ack, overflow;
	    logic full, empty, almostfull, almostempty, underflow;
	    int RD_EN_ON_DIST, WR_EN_ON_DIST;

	    function new(input int a = 30, b = 40);
	    	RD_EN_ON_DIST = a;
	    	WR_EN_ON_DIST = b;	
	    endfunction 

	    constraint reset {
	    	rst_n dist {0 := 3, 1 := 97};	
	    }
	    constraint write {
	    	wr_en dist {1 := WR_EN_ON_DIST, 0 := 100 - WR_EN_ON_DIST};
	    }
	    constraint read {
	    	rd_en dist {1 := RD_EN_ON_DIST, 0 := 100 - RD_EN_ON_DIST};
	    }
	endclass
	
endpackage 