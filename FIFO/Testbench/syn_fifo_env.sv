// 12. syn_fifo_env.sv
class syn_fifo_env extends uvm_env;
  `uvm_component_utils(syn_fifo_env)

  syn_fifo_active_agent  act_agent;
  syn_fifo_passive_agent pass_agent;
  syn_fifo_scoreboard    scb;
  syn_fifo_subscriber    sub;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    act_agent  = syn_fifo_active_agent::type_id::create("act_agent", this);
    pass_agent = syn_fifo_passive_agent::type_id::create("pass_agent", this);
    scb        = syn_fifo_scoreboard::type_id::create("scb", this);
    sub        = syn_fifo_subscriber::type_id::create("sub", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    act_agent.in_mon.in_ap.connect(scb.in_imp);
    act_agent.in_mon.in_ap.connect(sub.in_imp);

    pass_agent.out_mon.out_ap.connect(scb.out_imp);
    pass_agent.out_mon.out_ap.connect(sub.out_imp);
  endfunction
endclass
