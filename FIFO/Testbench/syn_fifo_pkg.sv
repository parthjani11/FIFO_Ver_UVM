`ifndef SYN_FIFO_PKG_SV
`define SYN_FIFO_PKG_SV

package syn_fifo_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // ADD THIS LINE to make macros visible to all classes in the package
  `include "syn_fifo_defines.svh" 

  `include "syn_fifo_item.sv"
  `include "syn_fifo_seq_lib.sv"
  `include "syn_fifo_sequencer.sv"
  `include "syn_fifo_driver.sv"
  `include "syn_fifo_in_monitor.sv"
  `include "syn_fifo_out_monitor.sv"
  `include "syn_fifo_active_agent.sv"
  `include "syn_fifo_passive_agent.sv"
  `include "syn_fifo_subscriber.sv"
  `include "syn_fifo_scoreboard.sv"
  `include "syn_fifo_env.sv"
  `include "syn_fifo_test_lib.sv"

endpackage

`endif
