// 7. syn_fifo_out_monitor.sv
class syn_fifo_out_monitor extends uvm_monitor;
  `uvm_component_utils(syn_fifo_out_monitor)

  virtual syn_fifo_if.MONITOR vif;
  uvm_analysis_port #(syn_fifo_item) out_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    out_ap = new("out_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual syn_fifo_if.MONITOR)::get(this, "", "vif", vif))
      `uvm_fatal("OUTMON", "virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.rd_cs && vif.mon_cb.rd_en) begin
        bit was_empty = vif.mon_cb.empty;
        syn_fifo_item item = syn_fifo_item::type_id::create("item");
        item.rd_cs  = 1;
        item.rd_en  = 1;
        item.empty  = was_empty;
        @(vif.mon_cb);
        item.data_out = vif.mon_cb.data_out;
        out_ap.write(item);
      end
    end
  endtask
endclass
