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

  int unsigned passed_cnt = 0;
  int unsigned failed_cnt = 0;
  string       failed_names[$];

  function new(string name, uvm_component parent); 
    super.new(name, parent); 
  endfunction

  task execute_testcase(uvm_sequence_base seq, string test_name);
    int unsigned initial_mismatches = env.scb.mismatch_cnt;
    
    // TELL THE SCOREBOARD WHICH TESTCASE IS ABOUT TO RUN
    env.scb.current_test_name = test_name; 

    `uvm_info("REGRESSION", $sformatf("Starting testcase: %s...", test_name), UVM_LOW)
    seq.start(env.act_agent.seqr);
    
    if (env.scb.mismatch_cnt > initial_mismatches) begin
      failed_cnt++;
      failed_names.push_back(test_name);
      `uvm_error("REGRESSION", $sformatf("Testcase FAILED: %s", test_name))
    end else begin
      passed_cnt++;
      `uvm_info("REGRESSION", $sformatf("Testcase PASSED: %s", test_name), UVM_LOW)
    end
  endtask

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

    // Execute each sequence through the tracking wrapper
    execute_testcase(s1, "syn_fifo_fill_to_full_seq");
    execute_testcase(s2, "syn_fifo_drain_to_empty_seq");
    execute_testcase(s3, "syn_fifo_boundary_simultaneous_seq");
    execute_testcase(s4, "syn_fifo_wrap_stream_seq");
    execute_testcase(s5, "syn_fifo_random_seq");

    #100;
    phase.drop_objection(this);
  endtask

  // Print the final pass/fail summary table at the very end of the simulation
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SUMMARY", "==================================================", UVM_NONE)
    `uvm_info("SUMMARY", "               REGRESSION TEST SUMMARY            ", UVM_NONE)
    `uvm_info("SUMMARY", "==================================================", UVM_NONE)
    `uvm_info("SUMMARY", $sformatf(" Total Testcases Passed : %0d", passed_cnt), UVM_NONE)
    `uvm_info("SUMMARY", $sformatf(" Total Testcases Failed : %0d", failed_cnt), UVM_NONE)
    
    if (failed_cnt > 0) begin
      `uvm_info("SUMMARY", "--------------------------------------------------", UVM_NONE)
      `uvm_info("SUMMARY", " LIST OF FAILED TESTCASES:", UVM_NONE)
      foreach (failed_names[i]) begin
        `uvm_info("SUMMARY", $sformatf("  -> %s", failed_names[i]), UVM_NONE)
      end
    end
    `uvm_info("SUMMARY", "==================================================", UVM_NONE)
  endfunction
endclass
