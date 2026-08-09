// 8. syn_fifo_active_agent.sv
class syn_fifo_active_agent extends uvm_agent;
  `uvm_component_utils(syn_fifo_active_agent)

  syn_fifo_sequencer  seqr;
  syn_fifo_driver     drv;
  syn_fifo_in_monitor in_mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr   = syn_fifo_sequencer::type_id::create("seqr", this);
    drv    = syn_fifo_driver::type_id::create("drv", this);
    in_mon = syn_fifo_in_monitor::type_id::create("in_mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
