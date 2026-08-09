// 2. syn_fifo_item.sv
class syn_fifo_item extends uvm_sequence_item;

  rand bit                  wr_cs;
  rand bit                  wr_en;
  rand bit                  rd_cs;
  rand bit                  rd_en;
  rand bit [`DATA_WIDTH-1:0] data_in;

       bit [`DATA_WIDTH-1:0] data_out;
       bit                   full;
       bit                   empty;

  constraint c_default {
    wr_cs dist {1 :/ 90, 0 :/ 10};
    rd_cs dist {1 :/ 90, 0 :/ 10};
    wr_en dist {1 :/ 80, 0 :/ 20};
    rd_en dist {1 :/ 80, 0 :/ 20};
  }

  `uvm_object_utils_begin(syn_fifo_item)
    `uvm_field_int(wr_cs,    UVM_ALL_ON)
    `uvm_field_int(wr_en,    UVM_ALL_ON)
    `uvm_field_int(rd_cs,    UVM_ALL_ON)
    `uvm_field_int(rd_en,    UVM_ALL_ON)
    `uvm_field_int(data_in,  UVM_ALL_ON)
    `uvm_field_int(data_out, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(full,     UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(empty,    UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "syn_fifo_item");
    super.new(name);
  endfunction

endclass
