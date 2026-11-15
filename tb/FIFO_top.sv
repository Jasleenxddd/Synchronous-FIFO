module FIFO_top ();
    bit clk;
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end
    FIFO_if #(.FIFO_WIDTH(16), .FIFO_DEPTH(8)) F_if(clk);
    FIFO DUT(F_if);
    FIFO_tb TEST(F_if);
    FIFO_monitor MONITOR(F_if);
    `ifdef SIM
    property async_reset_p;
        @(posedge F_if.clk) disable iff (F_if.rst_n) (!F_if.rst_n |-> F_if.empty);
    endproperty
    async_reset_assertion: assert property(async_reset_p) else $display("Async reset assertion failed at %t", $time);
    async_reset_coverage: cover property(async_reset_p);
    `endif
endmodule : FIFO_top