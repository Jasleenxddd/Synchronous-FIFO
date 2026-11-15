package FIFO_coverage_pkg;
	import FIFO_transaction_pkg::*;
	class FIFO_coverage;
		FIFO_transaction F_cvg_txn = new;
		covergroup cg;
		cp_data_in:     coverpoint  F_cvg_txn.data_in;
		cp_wr_en:       coverpoint  F_cvg_txn.wr_en;
		cp_rd_en:       coverpoint  F_cvg_txn.rd_en;
		cp_rst:         coverpoint  F_cvg_txn.rst_n;
		cp_full:        coverpoint  F_cvg_txn.full;
		cp_empty:       coverpoint  F_cvg_txn.empty;
		cp_almostfull:  coverpoint  F_cvg_txn.almostfull;
		cp_almostempty: coverpoint  F_cvg_txn.almostempty;
		cp_wr_Ack:      coverpoint  F_cvg_txn.wr_ack;
		cp_overflow:    coverpoint  F_cvg_txn.overflow;
		cp_underflow:   coverpoint  F_cvg_txn.underflow;
		cp_data_out:    coverpoint  F_cvg_txn.data_out;

		cross1: cross cp_rd_en, cp_wr_en, cp_wr_Ack{
		bins wr1_rd0_ack1 = binsof(cp_wr_en) intersect{1} && binsof(cp_rd_en) intersect{0} && binsof(cp_wr_Ack) intersect{1};
		bins wr0_rd1_ack0 = binsof(cp_wr_en) intersect{0} && binsof(cp_rd_en) intersect{1} && binsof(cp_wr_Ack) intersect{0};
		option.cross_auto_bin_max = 0;  
		}
		cross2: cross cp_rd_en, cp_wr_en, cp_full{
		bins wr1_rd0_full = binsof(cp_wr_en) intersect{1} && binsof(cp_rd_en) intersect{0} && binsof(cp_full);
		bins wr0_rd1_full = binsof(cp_wr_en) intersect{0} && binsof(cp_rd_en) intersect{1} && binsof(cp_full);
		option.cross_auto_bin_max = 0;  
		} 

		cross3: cross cp_rd_en, cp_wr_en, cp_empty{
		bins wr1_rd0_empty = binsof(cp_wr_en) intersect{1} && binsof(cp_rd_en) intersect{0} && binsof(cp_empty);
		bins wr0_rd1_empty = binsof(cp_wr_en) intersect{0} && binsof(cp_rd_en) intersect{1} && binsof(cp_empty);
		option.cross_auto_bin_max = 0;  
		} 
		cross4: cross cp_rd_en, cp_wr_en, cp_almostfull{
		bins wr1_rd0_almostfull1 = binsof(cp_wr_en) intersect{1} && binsof(cp_rd_en) intersect{0} && binsof(cp_almostfull) intersect{1};
		bins wr0_rd1_almostfull0 = binsof(cp_wr_en) intersect{0} && binsof(cp_rd_en) intersect{1} && binsof(cp_almostfull) intersect{0};
		option.cross_auto_bin_max = 0;  
		}
		cross5: cross cp_rd_en, cp_wr_en, cp_almostempty{
		bins wr1_rd0_almostempty0 = binsof(cp_wr_en) intersect{1} && binsof(cp_rd_en) intersect{0} && binsof(cp_almostempty) intersect{0};
		bins wr0_rd1_almostempty1 = binsof(cp_wr_en) intersect{0} && binsof(cp_rd_en) intersect{1} && binsof(cp_almostempty) intersect{1};
		option.cross_auto_bin_max = 0;  
		} 
		cross6: cross cp_rd_en, cp_wr_en, cp_overflow{
		bins wr1_rd0_overflow1 = binsof(cp_wr_en) intersect{1} && binsof(cp_rd_en) intersect{0} && binsof(cp_overflow) intersect{1};
		bins wr0_rd1_overflow0 = binsof(cp_wr_en) intersect{0} && binsof(cp_rd_en) intersect{1} && binsof(cp_overflow) intersect{0};
		option.cross_auto_bin_max = 0;  
		} 
		cross7: cross cp_rd_en, cp_wr_en, cp_underflow{
		bins wr1_rd0_underflow0 = binsof(cp_wr_en) intersect{1} && binsof(cp_rd_en) intersect{0} && binsof(cp_underflow) intersect{0};
		bins wr0_rd1_underflow1 = binsof(cp_wr_en) intersect{0} && binsof(cp_rd_en) intersect{1} && binsof(cp_underflow) intersect{1};
		option.cross_auto_bin_max = 0;  
		} 

		endgroup : cg

		function new();
			cg = new();
		endfunction	

		function void sample_data (FIFO_transaction F_txn);
			this.F_cvg_txn = F_txn;
			cg.sample();
	    endfunction : sample_data 
	endclass : FIFO_coverage

endpackage : FIFO_coverage_pkg