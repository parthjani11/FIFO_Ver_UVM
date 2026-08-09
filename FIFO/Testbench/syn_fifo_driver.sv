// 4. syn_fifo_driver.sv
class syn_fifo_driver extends uvm_driver #(syn_fifo_item);
  `uvm_component_utils(syn_fifo_driver)

  virtual syn_fifo_if.DRIVER vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual syn_fifo_if.DRIVER)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    vif.drv_cb.wr_cs   <= 0;
    vif.drv_cb.wr_en   <= 0;
    vif.drv_cb.rd_cs   <= 0;
    vif.drv_cb.rd_en   <= 0;
    vif.drv_cb.data_in <= 0;
    wait (vif.rst === 0);
    @(vif.drv_cb);

    forever begin
      syn_fifo_item item;
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end
  endtask

  task drive_item(syn_fifo_item item);
    vif.drv_cb.wr_cs   <= item.wr_cs;
    vif.drv_cb.wr_en   <= item.wr_en;
    vif.drv_cb.rd_cs   <= item.rd_cs;
    vif.drv_cb.rd_en   <= item.rd_en;
    vif.drv_cb.data_in <= item.data_in;
    @(vif.drv_cb);
  endtask

endclass
