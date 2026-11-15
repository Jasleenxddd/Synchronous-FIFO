import FIFO_transaction_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_shared_pkg::*;
module FIFO_monitor(FIFO_if.MONITOR F_if); // Add .MONITOR modport
    FIFO_transaction F_T = new();
    FIFO_scoreboard F_S = new();
    FIFO_coverage F_C = new();
    initial begin
        forever begin
            @(negedge F_if.clk);
            F_T.data_in = F_if.data_in;
            F_T.wr_en = F_if.wr_en;
            F_T.rd_en = F_if.rd_en;
            F_T.rst_n = F_if.rst_n;
            F_T.data_out = F_if.data_out;
            F_T.full = F_if.full;
            F_T.empty = F_if.empty;
            F_T.almostfull = F_if.almostfull;
            F_T.almostempty = F_if.almostempty;
            F_T.overflow = F_if.overflow;
            F_T.underflow = F_if.underflow;
            F_T.wr_ack = F_if.wr_ack;
            fork
                begin
                    F_C.sample_data(F_T);
                end
                begin
                    F_S.check_data(F_T);
                end
            join
            if (test_finished) begin
                $display("correct_count = %d, error_count = %d", correct_count, error_count);
                $stop;
            end
        end
    end
endmodule