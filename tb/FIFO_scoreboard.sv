package FIFO_scoreboard_pkg;
    import FIFO_transaction_pkg::*;
    import FIFO_shared_pkg::*;

    class FIFO_scoreboard;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;
        localparam max_fifo_addr = $clog2(FIFO_DEPTH);

        logic [FIFO_WIDTH-1:0] data_out_ref;
        logic wr_ack_ref, overflow_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
        logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];
        logic [max_fifo_addr-1:0] wr_ptr_ref, rd_ptr_ref;
        logic [max_fifo_addr:0] count_ref;

        function void check_data(FIFO_transaction txn);
            reference_model(txn);
            if (txn.data_out != data_out_ref || txn.wr_ack != wr_ack_ref 
             || txn.full != full_ref || txn.overflow != overflow_ref ||
                txn.empty != empty_ref || txn.almostfull != almostfull_ref ||
                txn.almostempty != almostempty_ref || txn.underflow != underflow_ref) begin 
                $display("Error at %0t: Mismatch detected", $time);
                error_count++;
            end else begin
                correct_count++;
            end
        endfunction : check_data

       function void reference_model(FIFO_transaction txn);
    // Snapshot current count and derived flags BEFORE applying the transaction
    logic [max_fifo_addr:0] prev_count;
    bit prev_full, prev_empty;

    prev_count = count_ref;
    prev_full  = (prev_count == FIFO_DEPTH);
    prev_empty = (prev_count == 0);

    if (!txn.rst_n) begin
        // asynchronous reset: force all refs to reset state
        data_out_ref    = 0;
        wr_ack_ref      = 0;
        overflow_ref    = 0;
        full_ref        = 0;
        empty_ref       = 1;
        almostfull_ref  = 0;
        almostempty_ref = 0;
        underflow_ref   = 0;
        count_ref       = 0;
        wr_ptr_ref      = 0;
        rd_ptr_ref      = 0;
    end
    else begin
        // default clear transients — will be set as needed below
        wr_ack_ref    = 0;
        overflow_ref  = 0;
        underflow_ref = 0;

        // Handle combinations according to spec:
        if (txn.wr_en && txn.rd_en) begin
            // both asserted: behavior depends on current occupancy
            if (prev_empty) begin
                // empty -> only write occurs
                mem_ref[wr_ptr_ref] = txn.data_in;
                wr_ack_ref = 1;
                wr_ptr_ref = (wr_ptr_ref + 1) % FIFO_DEPTH;
                count_ref  = count_ref + 1;
            end
            else if (prev_full) begin
                // full -> only read occurs
                data_out_ref = mem_ref[rd_ptr_ref];
                rd_ptr_ref   = (rd_ptr_ref + 1) % FIFO_DEPTH;
                count_ref    = count_ref - 1;
                wr_ack_ref   = 0; // explicit
            end
            else begin
                // normal -> do both (read and write), count unchanged
                mem_ref[wr_ptr_ref] = txn.data_in;
                data_out_ref        = mem_ref[rd_ptr_ref];
                wr_ack_ref = 1;
                wr_ptr_ref = (wr_ptr_ref + 1) % FIFO_DEPTH;
                rd_ptr_ref = (rd_ptr_ref + 1) % FIFO_DEPTH;
                // count_ref unchanged
            end
        end
        else if (txn.wr_en) begin
            // write only
            if (!prev_full) begin
                mem_ref[wr_ptr_ref] = txn.data_in;
                wr_ack_ref = 1;
                wr_ptr_ref = (wr_ptr_ref + 1) % FIFO_DEPTH;
                count_ref  = count_ref + 1;
                overflow_ref = 0;
            end else begin
                // attempt to write when full -> reject write
                wr_ack_ref   = 0;
                overflow_ref = 1;
                // no pointer/count change
            end
        end
        else if (txn.rd_en) begin
            // read only
            if (!prev_empty) begin
                data_out_ref = mem_ref[rd_ptr_ref];
                rd_ptr_ref   = (rd_ptr_ref + 1) % FIFO_DEPTH;
                count_ref    = count_ref - 1;
                wr_ack_ref   = 0;
            end else begin
                // attempt to read when empty -> underflow
                wr_ack_ref    = 0;
                underflow_ref = 1;
            end
        end
        else begin
            // neither read nor write: keep defaults (wr_ack = 0, etc.)
            wr_ack_ref = 0;
        end

        // Recompute status flags from the updated count_ref
        full_ref        = (count_ref == FIFO_DEPTH);
        empty_ref       = (count_ref == 0);
        almostfull_ref  = (count_ref == FIFO_DEPTH - 1);
        almostempty_ref = (count_ref == 1);
    end
endfunction : reference_model

    endclass	
	
endpackage : FIFO_scoreboard_pkg