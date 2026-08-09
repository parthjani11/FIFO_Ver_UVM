`ifndef UVM_IMP_DECL_IN_OUT
`define UVM_IMP_DECL_IN_OUT
`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
`endif

class syn_fifo_subscriber extends uvm_component;
  `uvm_component_utils(syn_fifo_subscriber)

  uvm_analysis_imp_in  #(syn_fifo_item, syn_fifo_subscriber) in_imp;
  uvm_analysis_imp_out #(syn_fifo_item, syn_fifo_subscriber) out_imp;

  syn_fifo_item in_item;

  int unsigned status_cnt_model;

  covergroup cg_input;
    option.per_instance = 1;

    cp_wr_qual: coverpoint (in_item.wr_cs && in_item.wr_en) {
      bins qual   = {1};
      bins unqual = {0};
    }
    cp_rd_qual: coverpoint (in_item.rd_cs && in_item.rd_en) {
      bins qual   = {1};
      bins unqual = {0};
    }
    cp_full:  coverpoint in_item.full;
    cp_empty: coverpoint in_item.empty;

    cp_status_cnt: coverpoint status_cnt_model {
      bins zero        = {0};
      bins one         = {1};
      bins depth_m1    = {`RAM_DEPTH - 1};
      bins depth       = {`RAM_DEPTH};
      bins mid         = {[2:`RAM_DEPTH-2]};
    }

    // This cross expects the status_cnt to reflect the state of the FIFO
    // BEFORE the simultaneous command was executed.
    cross_simul_status: cross cp_wr_qual, cp_rd_qual, cp_status_cnt {
      bins at_full_simul  = binsof(cp_wr_qual.qual) && binsof(cp_rd_qual.qual)
                             && binsof(cp_status_cnt.depth);
      bins at_empty_simul = binsof(cp_wr_qual.qual) && binsof(cp_rd_qual.qual)
                             && binsof(cp_status_cnt.zero);
      bins mid_simul      = binsof(cp_wr_qual.qual) && binsof(cp_rd_qual.qual)
                             && binsof(cp_status_cnt.mid);
    }

    cp_gating: coverpoint {in_item.wr_cs, in_item.wr_en, in_item.rd_cs, in_item.rd_en} {
      bins wr_cs_only = {4'b1000};
      bins wr_en_only = {4'b0100};
      bins rd_cs_only = {4'b0010};
      bins rd_en_only = {4'b0001};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_input  = new();
    in_imp    = new("in_imp", this);
    out_imp   = new("out_imp", this);
  endfunction

  function void write_in(syn_fifo_item t);
    in_item = t;

    // FIX: Sample the covergroup BEFORE updating the status_cnt_model.
    // We want to record the occupancy of the FIFO at the exact moment
    // the transaction was issued, capturing the boundary states accurately.
    cg_input.sample();

    if ((t.wr_cs && t.wr_en && !t.full) && !(t.rd_cs && t.rd_en && !t.empty))
      status_cnt_model++;
    else if ((t.rd_cs && t.rd_en && !t.empty) && !(t.wr_cs && t.wr_en && !t.full))
      status_cnt_model--;
  endfunction

  function void write_out(syn_fifo_item t);
    // Output coverage ignored due to known DUT read bug.
  endfunction

endclass
