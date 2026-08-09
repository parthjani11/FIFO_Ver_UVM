// 1. syn_fifo_if.sv
interface syn_fifo_if #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 8
) (input logic clk, input logic rst);

  localparam RAM_DEPTH = 1 << ADDR_WIDTH;

  logic                  wr_cs;
  logic                  wr_en;
  logic                  rd_cs;
  logic                  rd_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic                  full;
  logic                  empty;

  clocking drv_cb @(posedge clk);
    default input #1step output #2;
    output wr_cs, wr_en, rd_cs, rd_en, data_in;
    input  full, empty, data_out;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step output #2;
    input wr_cs, wr_en, rd_cs, rd_en, data_in, data_out, full, empty;
  endclocking

  modport DRIVER (clocking drv_cb, input clk, rst);
  modport MONITOR (clocking mon_cb, input clk, rst);

  // ---------------------------------------------------------------
  // Assertions - bound in here so they run for every test automatically
  // ---------------------------------------------------------------
  property p_no_write_when_full;
    @(posedge clk) disable iff (rst)
      (wr_cs && wr_en && full) |=> $stable(data_out) or 1'b1; 
  endproperty

  // full/empty mutual exclusivity
  property p_full_empty_excl;
    @(posedge clk) disable iff (rst)
      not (full && empty);
  endproperty
  assert property (p_full_empty_excl)
    else $error("SVA: full and empty asserted simultaneously");

  // data_out must hold steady across a blocked (empty) read
  property p_data_out_holds_on_blocked_read;
    @(posedge clk) disable iff (rst)
      (rd_cs && rd_en && empty) |=> $stable(data_out);
  endproperty
  assert property (p_data_out_holds_on_blocked_read)
    else $error("SVA: data_out changed during a blocked read while empty");

  // data_out must never go X after a qualified read
  property p_data_out_known_after_read;
    @(posedge clk) disable iff (rst)
      (rd_cs && rd_en && !empty) |=> !$isunknown(data_out);
  endproperty
  assert property (p_data_out_known_after_read)
    else $error("SVA: data_out unknown after qualified read");

  cover property (@(posedge clk) disable iff (rst) (wr_cs && wr_en && rd_cs && rd_en));
  cover property (@(posedge clk) disable iff (rst) full);
  cover property (@(posedge clk) disable iff (rst) empty);

endinterface
