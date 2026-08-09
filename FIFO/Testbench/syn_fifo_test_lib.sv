class syn_fifo_base_test extends uvm_test;
  `uvm_component_utils(syn_fifo_base_test)

  syn_fifo_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = syn_fifo_env::type_id::create("env", this);
  endfunction

  virtual function uvm_sequence_base get_seq();
    `uvm_fatal("TEST", "get_seq() must be overridden")
  endfunction

  task run_phase(uvm_phase phase);
    uvm_sequence_base seq;
    phase.raise_objection(this);
    seq = get_seq();
    seq.start(env.act_agent.seqr);
    #100;
    phase.drop_objection(this);
  endtask
endclass

class syn_fifo_fill_full_test extends syn_fifo_base_test;
  `uvm_component_utils(syn_fifo_fill_full_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function uvm_sequence_base get_seq();
    return syn_fifo_fill_to_full_seq::type_id::create("seq");
  endfunction
endclass

class syn_fifo_drain_empty_test extends syn_fifo_base_test;
  `uvm_component_utils(syn_fifo_drain_empty_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function uvm_sequence_base get_seq();
    return syn_fifo_drain_to_empty_seq::type_id::create("seq");
  endfunction
endclass

class syn_fifo_boundary_simul_test extends syn_fifo_base_test;
  `uvm_component_utils(syn_fifo_boundary_simul_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function uvm_sequence_base get_seq();
    return syn_fifo_boundary_simultaneous_seq::type_id::create("seq");
  endfunction
endclass

class syn_fifo_wrap_test extends syn_fifo_base_test;
  `uvm_component_utils(syn_fifo_wrap_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function uvm_sequence_base get_seq();
    return syn_fifo_wrap_stream_seq::type_id::create("seq");
  endfunction
endclass

class syn_fifo_random_test extends syn_fifo_base_test;
  `uvm_component_utils(syn_fifo_random_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function uvm_sequence_base get_seq();
    syn_fifo_random_seq seq = syn_fifo_random_seq::type_id::create("seq");
    seq.num_items = 20000;
    return seq;
  endfunction
endclass

class syn_fifo_regression_test extends syn_fifo_base_test;
  `uvm_component_utils(syn_fifo_regression_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  task run_phase(uvm_phase phase);
    syn_fifo_fill_to_full_seq          s1;
    syn_fifo_drain_to_empty_seq        s2;
    syn_fifo_boundary_simultaneous_seq s3;
    syn_fifo_wrap_stream_seq           s4;
    syn_fifo_random_seq                s5;

    phase.raise_objection(this);

    s1 = syn_fifo_fill_to_full_seq::type_id::create("s1");
    s2 = syn_fifo_drain_to_empty_seq::type_id::create("s2");
    s3 = syn_fifo_boundary_simultaneous_seq::type_id::create("s3");
    s4 = syn_fifo_wrap_stream_seq::type_id::create("s4");
    s5 = syn_fifo_random_seq::type_id::create("s5");

    s4.total_ops = `RAM_DEPTH * 15; 
    s5.num_items = 50000; 

    s1.start(env.act_agent.seqr);
    s2.start(env.act_agent.seqr);
    s3.start(env.act_agent.seqr);
    s4.start(env.act_agent.seqr);
    s5.start(env.act_agent.seqr);

    #100;
    phase.drop_objection(this);
  endtask
endclass
