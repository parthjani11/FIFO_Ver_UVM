// 3. syn_fifo_seq_lib.sv
class syn_fifo_base_seq extends uvm_sequence #(syn_fifo_item);
  `uvm_object_utils(syn_fifo_base_seq)

  function new(string name = "syn_fifo_base_seq");
    super.new(name);
  endfunction

  task idle_cycle();
    syn_fifo_item item = syn_fifo_item::type_id::create("item");
    start_item(item);
    void'(item.randomize() with {
      wr_cs == 0; wr_en == 0; rd_cs == 0; rd_en == 0;
    });
    finish_item(item);
  endtask

  task do_write(bit [`DATA_WIDTH-1:0] d);
    syn_fifo_item item = syn_fifo_item::type_id::create("item");
    start_item(item);
    void'(item.randomize() with {
      wr_cs == 1; wr_en == 1; rd_cs == 0; rd_en == 0; data_in == d;
    });
    finish_item(item);
  endtask

  task do_read();
    syn_fifo_item item = syn_fifo_item::type_id::create("item");
    start_item(item);
    void'(item.randomize() with {
      wr_cs == 0; wr_en == 0; rd_cs == 1; rd_en == 1;
    });
    finish_item(item);
  endtask

  task do_simultaneous(bit [`DATA_WIDTH-1:0] d);
    syn_fifo_item item = syn_fifo_item::type_id::create("item");
    start_item(item);
    void'(item.randomize() with {
      wr_cs == 1; wr_en == 1; rd_cs == 1; rd_en == 1; data_in == d;
    });
    finish_item(item);
  endtask
endclass

class syn_fifo_fill_to_full_seq extends syn_fifo_base_seq;
  `uvm_object_utils(syn_fifo_fill_to_full_seq)
  int unsigned depth = `RAM_DEPTH;

  function new(string name = "syn_fifo_fill_to_full_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < depth; i++) do_write(i[`DATA_WIDTH-1:0]);
    repeat (3) do_write($urandom);
  endtask
endclass

class syn_fifo_drain_to_empty_seq extends syn_fifo_base_seq;
  `uvm_object_utils(syn_fifo_drain_to_empty_seq)
  int unsigned depth = `RAM_DEPTH;

  function new(string name = "syn_fifo_drain_to_empty_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < depth; i++) do_read();
    repeat (3) do_read();
  endtask
endclass

class syn_fifo_fill_drain_seq extends syn_fifo_base_seq;
  `uvm_object_utils(syn_fifo_fill_drain_seq)

  function new(string name = "syn_fifo_fill_drain_seq");
    super.new(name);
  endfunction

  task body();
    syn_fifo_fill_to_full_seq fill_seq;
    syn_fifo_drain_to_empty_seq drain_seq;
    fill_seq  = syn_fifo_fill_to_full_seq::type_id::create("fill_seq");
    drain_seq = syn_fifo_drain_to_empty_seq::type_id::create("drain_seq");
    fill_seq.start(m_sequencer);
    drain_seq.start(m_sequencer);
  endtask
endclass

class syn_fifo_boundary_simultaneous_seq extends syn_fifo_base_seq;
  `uvm_object_utils(syn_fifo_boundary_simultaneous_seq)
  int unsigned depth = `RAM_DEPTH;

  function new(string name = "syn_fifo_boundary_simultaneous_seq");
    super.new(name);
  endfunction

  task body();
    // fill to full
    for (int i = 0; i < depth; i++) do_write(i[`DATA_WIDTH-1:0]);

    // idle cycle to guarantee the DUT's 'full' flag has transitioned
    idle_cycle();

    // D2: simultaneous R+W AT full - write should be blocked, read qualifies.
    // This drops the occupancy from depth down to depth - 1.
    do_simultaneous($urandom);

    // FIX: Inject an idle cycle right here while the FIFO is exactly at depth - 1.
    // This perfectly hits the (unqual, unqual, depth_m1) bin.
    idle_cycle();

    // D4: now at depth-1, simultaneous R+W - both qualify, unchanged
    do_simultaneous($urandom);

    // drain fully to empty
    for (int i = 0; i < depth - 1; i++) do_read();

    // idle cycle to guarantee the DUT's 'empty' flag has transitioned
    idle_cycle();

    // D3: simultaneous R+W AT empty - read blocked, write qualifies.
    // This raises the occupancy from 0 up to 1.
    do_simultaneous($urandom);

    // FIX: Inject an idle cycle right here while the FIFO is exactly at 1.
    // This ensures the symmetric (unqual, unqual, one) bin is forcefully hit.
    idle_cycle();

    // D5: now at status_cnt=1, simultaneous R+W - both qualify, unchanged
    do_simultaneous($urandom);
  endtask
endclass

class syn_fifo_wrap_stream_seq extends syn_fifo_base_seq;
  `uvm_object_utils(syn_fifo_wrap_stream_seq)
  int unsigned total_ops = `RAM_DEPTH * 3;

  function new(string name = "syn_fifo_wrap_stream_seq");
    super.new(name);
  endfunction

  task body();
    bit [`DATA_WIDTH-1:0] pattern;
    for (int i = 0; i < `RAM_DEPTH/2; i++) do_write(i[`DATA_WIDTH-1:0]);

    for (int i = 0; i < total_ops; i++) begin
      pattern = i[`DATA_WIDTH-1:0];
      if (i % 2 == 0) do_write(pattern);
      else            do_read();
    end
  endtask
endclass

class syn_fifo_continuous_traffic_seq extends syn_fifo_base_seq;
  `uvm_object_utils(syn_fifo_continuous_traffic_seq)
  int unsigned num_items = 200;

  function new(string name = "syn_fifo_continuous_traffic_seq");
    super.new(name);
  endfunction

  task body();
    syn_fifo_item item;
    repeat (num_items) begin
      item = syn_fifo_item::type_id::create("item");
      start_item(item);
      void'(item.randomize());
      finish_item(item);
    end
  endtask
endclass

class syn_fifo_random_seq extends syn_fifo_base_seq;
  `uvm_object_utils(syn_fifo_random_seq)
  int unsigned num_items = 2000;

  function new(string name = "syn_fifo_random_seq");
    super.new(name);
  endfunction

  task body();
    syn_fifo_item item;
    repeat (num_items) begin
      item = syn_fifo_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
            (wr_cs && wr_en && rd_cs && rd_en) dist {1 :/ 40, 0 :/ 60};
          })
        `uvm_error("RANDSEQ", "Randomization failed")
      finish_item(item);
    end
  endtask
endclass
