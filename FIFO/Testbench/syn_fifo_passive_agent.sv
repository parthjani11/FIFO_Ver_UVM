class syn_fifo_passive_agent extends uvm_agent;
  `uvm_component_utils(syn_fifo_passive_agent)

  syn_fifo_out_monitor out_mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    out_mon = syn_fifo_out_monitor::type_id::create("out_mon", this);
    
    // FIX: Directly assign the variable instead of using a setter method
    is_active = UVM_PASSIVE;
  endfunction
endclass
