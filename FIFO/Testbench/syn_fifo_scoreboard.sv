// 11. syn_fifo_scoreboard.sv
`ifndef UVM_IMP_DECL_IN_OUT
`define UVM_IMP_DECL_IN_OUT
`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
`endif

class syn_fifo_scoreboard extends uvm_component;
  `uvm_component_utils(syn_fifo_scoreboard)

  uvm_analysis_imp_in  #(syn_fifo_item, syn_fifo_scoreboard) in_imp;
  uvm_analysis_imp_out #(syn_fifo_item, syn_fifo_scoreboard) out_imp;

  bit [`DATA_WIDTH-1:0] ref_mem [`RAM_DEPTH];
  int unsigned wr_pointer_model;
  int unsigned rd_pointer_model;
  int unsigned status_cnt_model;

  bit [`DATA_WIDTH-1:0] expected_data_q[$];
  bit                   expected_blocked_q[$];

  int unsigned match_cnt;
  int unsigned mismatch_cnt;
  int unsigned blocked_read_checks;
  int unsigned overflow_block_checks;

  string current_test_name = "INITIALIZATION";

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    in_imp  = new("in_imp", this);
    out_imp = new("out_imp", this);
  endfunction

  function void write_in(syn_fifo_item t);
    bit wr_valid, rd_valid;

    wr_valid = t.wr_cs && t.wr_en && !t.full;
    rd_valid = t.rd_cs && t.rd_en && !t.empty;

    if (t.full  !== (status_cnt_model == `RAM_DEPTH))
      `uvm_error("SCB", $sformatf("full mismatch: dut=%0b model_cnt=%0d", t.full, status_cnt_model))
    if (t.empty !== (status_cnt_model == 0))
      `uvm_error("SCB", $sformatf("empty mismatch: dut=%0b model_cnt=%0d", t.empty, status_cnt_model))

    if (wr_valid) begin
      ref_mem[wr_pointer_model] = t.data_in;
      wr_pointer_model = (wr_pointer_model + 1) % `RAM_DEPTH;
    end else if (t.wr_cs && t.wr_en && t.full) begin
      overflow_block_checks++;
    end

    if (rd_valid) begin
      expected_data_q.push_back(ref_mem[rd_pointer_model]);
      expected_blocked_q.push_back(0);
      rd_pointer_model = (rd_pointer_model + 1) % `RAM_DEPTH;
    end else if (t.rd_cs && t.rd_en && t.empty) begin
      expected_blocked_q.push_back(1);
      blocked_read_checks++;
    end

    if (wr_valid && !rd_valid) status_cnt_model++;
    else if (rd_valid && !wr_valid) status_cnt_model--;
  endfunction

  bit [`DATA_WIDTH-1:0] last_valid_data_out;

  function void write_out(syn_fifo_item t);
    if (expected_blocked_q.size() == 0) begin
      `uvm_error("SCB", "Received data_out sample with no pending expectation queued")
      return;
    end

    if (expected_blocked_q.pop_front() == 1) begin
      if (t.data_out !== last_valid_data_out) begin
        mismatch_cnt++;
        // ADD TEST NAME TO THIS PRINT
        `uvm_error("SCB", $sformatf(
          "[%s] Blocked-read data_out changed! exp(held)=%0h act=%0h",
          current_test_name, last_valid_data_out, t.data_out)) 
      end else begin
        match_cnt++;
      end
    end else begin
      bit [`DATA_WIDTH-1:0] exp_data = expected_data_q.pop_front();
      if (t.data_out === exp_data) begin
        match_cnt++;
      end else begin
        mismatch_cnt++;
        // ADD TEST NAME TO THIS PRINT
        `uvm_error("SCB", $sformatf(
          "[%s] data_out mismatch: exp=%0h act=%0h", 
          current_test_name, exp_data, t.data_out))
      end
      last_valid_data_out = t.data_out;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    int total_transactions = match_cnt + mismatch_cnt;
    
    `uvm_info("SCB", "==================================================", UVM_NONE)
    `uvm_info("SCB", "          SCOREBOARD TRANSACTION SUMMARY          ", UVM_NONE)
    `uvm_info("SCB", "==================================================", UVM_NONE)
    `uvm_info("SCB", $sformatf(" Total Read Transactions : %0d", total_transactions), UVM_NONE)
    `uvm_info("SCB", $sformatf(" Transactions PASSED     : %0d", match_cnt), UVM_NONE)
    `uvm_info("SCB", $sformatf(" Transactions FAILED     : %0d", mismatch_cnt), UVM_NONE)
    `uvm_info("SCB", "==================================================", UVM_NONE)
    
    if (mismatch_cnt > 0)
      `uvm_error("SCB", $sformatf("TEST FAILED with %0d mismatches out of %0d transactions", mismatch_cnt, total_transactions))
  endfunction
endclass
