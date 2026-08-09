// 5. syn_fifo_sequencer.sv
class syn_fifo_sequencer extends uvm_sequencer #(syn_fifo_item);
  `uvm_component_utils(syn_fifo_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
