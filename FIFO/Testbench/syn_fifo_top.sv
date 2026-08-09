// Replaced the standalone definitions with the include file
`include "syn_fifo_defines.svh"

import uvm_pkg::*;
`include "uvm_macros.svh"
import syn_fifo_pkg::*;

module syn_fifo_top;

  logic clk;
  logic rst;

  always #5 clk = ~clk;

  syn_fifo_if #(.DATA_WIDTH(`DATA_WIDTH), .ADDR_WIDTH(`ADDR_WIDTH)) vif (clk, rst);

  syn_fifo #(
    .DATA_WIDTH(`DATA_WIDTH),
    .ADDR_WIDTH(`ADDR_WIDTH)
  ) dut (
    .clk      (clk),
    .rst      (rst),
    .wr_cs    (vif.wr_cs),
    .wr_en    (vif.wr_en),
    .rd_cs    (vif.rd_cs),
    .rd_en    (vif.rd_en),
    .data_in  (vif.data_in),
    .data_out (vif.data_out),
    .full     (vif.full),
    .empty    (vif.empty)
  );

  initial begin
    clk = 0;
    rst = 1;
    repeat (3) @(posedge clk);
    rst = 0;
  end

  initial begin
    uvm_config_db#(virtual syn_fifo_if.DRIVER)::set(null, "*", "vif", vif.DRIVER);
    uvm_config_db#(virtual syn_fifo_if.MONITOR)::set(null, "*", "vif", vif.MONITOR);
    run_test();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, syn_fifo_top);
  end

endmodule
