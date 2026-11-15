////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design (Corrected)
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.DUT F_if);

    reg [F_if.FIFO_WIDTH-1:0] mem [F_if.FIFO_DEPTH-1:0];
    reg [F_if.max_fifo_addr-1:0] wr_ptr, rd_ptr;
    reg [F_if.max_fifo_addr:0] count;

    always @(posedge F_if.clk or negedge F_if.rst_n) begin
        if (!F_if.rst_n) begin
            wr_ptr          <= 0;
            F_if.wr_ack     <= 0;
            F_if.overflow   <= 0;
        end 
        else begin
            // Case 1: Simultaneous write & read
            if (F_if.wr_en && F_if.rd_en) begin
                if (F_if.empty) begin
                    // empty → only write occurs
                    mem[wr_ptr] <= F_if.data_in;
                    wr_ptr      <= wr_ptr + 1;
                    F_if.wr_ack <= 1;
                    F_if.overflow <= 0;
                end 
                else if (F_if.full) begin
                    // full → only read occurs (ignore write)
                    F_if.wr_ack   <= 0;
                    F_if.overflow <= 0;
                end 
                else begin
                    // normal simultaneous operation (no overflow)
                    mem[wr_ptr] <= F_if.data_in;
                    wr_ptr      <= wr_ptr + 1;
                    F_if.wr_ack <= 1;
                    F_if.overflow <= 0;
                end
            end
            // Case 2: Write only (no read)
            else if (F_if.wr_en && !F_if.full) begin
                mem[wr_ptr] <= F_if.data_in;
                wr_ptr      <= wr_ptr + 1;
                F_if.wr_ack <= 1;
                F_if.overflow <= 0;
            end
            // Case 3: Write when full → overflow
            else if (F_if.wr_en && F_if.full) begin
                F_if.wr_ack   <= 0;
                F_if.overflow <= 1;
            end
            // Case 4: No write
            else begin
                F_if.wr_ack   <= 0;
                F_if.overflow <= 0;
            end
        end
    end
    always @(posedge F_if.clk or negedge F_if.rst_n) begin
        if (!F_if.rst_n) begin
            rd_ptr          <= 0;
            F_if.data_out   <= 0;
            F_if.underflow  <= 0;
        end 
        else begin
            // Simultaneous read & write handled in write block (no harm if repeated)
            if (F_if.rd_en && !F_if.empty) begin
                F_if.data_out <= mem[rd_ptr];
                rd_ptr        <= rd_ptr + 1;
                F_if.underflow <= 0;
            end 
            else if (F_if.rd_en && F_if.empty && !F_if.wr_en) begin
                // underflow only if read when empty with no write
                F_if.underflow <= 1;
            end 
            else begin
                F_if.underflow <= 0;
            end
        end
    end
    always @(posedge F_if.clk or negedge F_if.rst_n) begin
        if (!F_if.rst_n)
            count <= 0;
        else begin
            case ({F_if.wr_en, F_if.rd_en})
                2'b10: if (!F_if.full)  count <= count + 1;   // write only
                2'b01: if (!F_if.empty) count <= count - 1;   // read only
                2'b11: begin
                    if (F_if.full)      count <= count - 1;   // full → only read
                    else if (F_if.empty)count <= count + 1;   // empty → only write
                    else                count <= count;        // mid → both valid
                end
                default: count <= count;                       // idle
            endcase
        end
    end
    assign F_if.full         = (count == F_if.FIFO_DEPTH);
    assign F_if.empty        = (count == 0);
    assign F_if.almostfull   = (count == F_if.FIFO_DEPTH - 1);
    assign F_if.almostempty  = (count == 1);

`ifdef SIM
    always_comb begin
        if(!F_if.rst_n) 
            assert_rst: assert final(!count && !wr_ptr && !rd_ptr && 
                                    !F_if.wr_ack && !F_if.full && 
                                    !F_if.overflow && !F_if.underflow);
    end

    property wr_ack_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (F_if.wr_en && !F_if.full) |=> F_if.wr_ack;
    endproperty

    property overflow_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (F_if.wr_en && F_if.full && !F_if.rd_en) |=> F_if.overflow;
    endproperty

    property underflow_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (F_if.rd_en && F_if.empty && !F_if.wr_en) |=> F_if.underflow;
    endproperty

    property empty_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (count == 0) |-> F_if.empty;
    endproperty

    property full_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (count == F_if.FIFO_DEPTH) |-> F_if.full;
    endproperty

    property almostempty_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (count == 1) |-> F_if.almostempty;
    endproperty

    property almostfull_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (count == F_if.FIFO_DEPTH-1) |-> F_if.almostfull;
    endproperty

    property wr_ptr_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (F_if.wr_en && !F_if.full) |=> (wr_ptr == (($past(wr_ptr)+1)% F_if.FIFO_DEPTH));
    endproperty

    property rd_ptr_p;
        @(posedge F_if.clk) disable iff(!F_if.rst_n)
        (F_if.rd_en && !F_if.empty) |=> (rd_ptr == (($past(rd_ptr)+1)% F_if.FIFO_DEPTH));
    endproperty

    property count_threshold_p;
        @(posedge F_if.clk) (count <= F_if.FIFO_DEPTH);
    endproperty

    property ptr_threshold_p;
        @(posedge F_if.clk) (wr_ptr < F_if.FIFO_DEPTH && rd_ptr < F_if.FIFO_DEPTH);
    endproperty

    // Assertions and coverage
    SVA_wr_ack_assertion:          assert property (wr_ack_p) else $display("failed in wr_ack at %t", $time);
    SVA_overflow_assertion:        assert property (overflow_p) else $display("failed in overflow at %t", $time);
    SVA_underflow_assertion:       assert property (underflow_p) else $display("failed in underflow at %t", $time);
    SVA_empty_assertion:           assert property (empty_p) else $display("failed in empty at %t", $time);
    SVA_full_assertion:            assert property (full_p) else $display("failed in full at %t", $time);
    SVA_almostfull_assertion:      assert property (almostfull_p) else $display("failed in almostfull at %t", $time);
    SVA_almostempty_assertion:     assert property (almostempty_p) else $display("failed in almostempty at %t", $time);
    SVA_wr_ptr_assertion:          assert property (wr_ptr_p) else $display("failed in wr_ptr at %t", $time);
    SVA_rd_ptr_assertion:          assert property (rd_ptr_p) else $display("failed in rd_ptr at %t", $time);
    SVA_count_threshold_assertion: assert property (count_threshold_p) else $display("failed in count_threshold at %t", $time);
    SVA_ptr_threshold_assertion:   assert property (ptr_threshold_p) else $display("failed in ptr_threshold at %t", $time);

    // Coverage
    SVA_wr_ack_coverage:           cover property (wr_ack_p);
    SVA_overflow_coverage:         cover property (overflow_p);
    SVA_underflow_coverage:        cover property (underflow_p);
    SVA_empty_coverage:            cover property (empty_p);
    SVA_full_coverage:             cover property (full_p);
    SVA_almostfull_coverage:       cover property (almostfull_p);
    SVA_almostempty_coverage:      cover property (almostempty_p);
    SVA_wr_ptr_coverage:           cover property (wr_ptr_p);
    SVA_rd_ptr_coverage:           cover property (rd_ptr_p);
    SVA_count_threshold_coverage:  cover property (count_threshold_p);
    SVA_ptr_threshold_coverage:    cover property (ptr_threshold_p);
`endif

endmodule
