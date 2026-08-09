// 6. syn_fifo_in_monitor.sv
class syn_fifo_in_monitor extends uvm_monitor;
  `uvm_component_utils(syn_fifo_in_monitor)

  virtual syn_fifo_if.MONITOR vif;
  uvm_analysis_port #(syn_fifo_item) in_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_ap = new("in_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual syn_fifo_if.MONITOR)::get(this, "", "vif", vif))
      `uvm_fatal("INMON", "virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      syn_fifo_item item;
      @(vif.mon_cb);
      item = syn_fifo_item::type_id::create("item");
      item.wr_cs   = vif.mon_cb.wr_cs;
      item.wr_en   = vif.mon_cb.wr_en;
      item.rd_cs   = vif.mon_cb.rd_cs;
      item.rd_en   = vif.mon_cb.rd_en;
      item.data_in = vif.mon_cb.data_in;
      item.full    = vif.mon_cb.full;
      item.empty   = vif.mon_cb.empty;
      in_ap.write(item);
    end
  endtask
endclass
