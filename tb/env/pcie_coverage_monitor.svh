class pcie_coverage_monitor extends uvm_component;

  `uvm_component_utils(pcie_coverage_monitor)

  lpif_seq_item lpif_seq_item_h;
  pipe_seq_item pipe_seq_item_h;
  uvm_analysis_export #(lpif_seq_item) lpif_export_sent;
  uvm_analysis_imp_lpif_received #(lpif_seq_item, pcie_coverage_monitor) lpif_export_received;
  uvm_analysis_export #(pipe_seq_item) pipe_export_sent;
  uvm_analysis_imp_pipe_received #(pipe_seq_item, pcie_coverage_monitor) pipe_export_received;
  uvm_tlm_analysis_fifo #(lpif_seq_item) lpif_fifo;
  uvm_tlm_analysis_fifo #(pipe_seq_item) pipe_fifo;

  //=============================================================================================
  // Environment-Level Cross-Interface Coverage
  // Covers system-level scenarios spanning LPIF and PIPE interfaces
  // Added 'iff' conditions to ensure simulation stability by checking for null handles
  //=============================================================================================
  covergroup pcie_env_cov;
    
    //========== LPIF Operation Coverage ==========
    // Check if LPIF sequence item is not null before sampling to prevent SIGSEGV
    cp_lpif_op : coverpoint lpif_seq_item_h.lpif_operation iff (lpif_seq_item_h != null) {
      bins link_reset    = {lpif_agent_pkg::LINK_RESET};
      bins link_up       = {lpif_agent_pkg::LINK_UP};
      bins tlp_transfer  = {lpif_agent_pkg::TLP_TRANSFER};
      bins dllp_transfer = {lpif_agent_pkg::DLLP_TRANSFER};
      bins enter_retrain = {lpif_agent_pkg::ENTER_RETRAIN};
      bins send_data     = {lpif_agent_pkg::SEND_DATA};
    }

    //========== LPIF Speed Mode Coverage ==========
    // Guarded by null check to ensure simulation stability
    cp_lpif_speed : coverpoint lpif_seq_item_h.speed_mode iff (lpif_seq_item_h != null) {
      bins gen1 = {lpif_agent_pkg::LPIF_GEN1};
      bins gen2 = {lpif_agent_pkg::LPIF_GEN2};
      bins gen3 = {lpif_agent_pkg::LPIF_GEN3};
      bins gen4 = {lpif_agent_pkg::LPIF_GEN4};
      bins gen5 = {lpif_agent_pkg::LPIF_GEN5};
    }

    //========== PIPE Operation Coverage ==========
    // Guarded by null check for PIPE sequence item
    cp_pipe_op : coverpoint pipe_seq_item_h.pipe_operation iff (pipe_seq_item_h != null) {
      bins reset        = {pipe_agent_pkg::RESET};
      bins link_up      = {pipe_agent_pkg::LINK_UP};
      bins tlp_transfer = {pipe_agent_pkg::TLP_TRANSFER};
      bins speed_change = {pipe_agent_pkg::SPEED_CHANGE};
      bins send_ts      = {pipe_agent_pkg::SEND_TS};
    }

    //========== PIPE Generation Coverage ==========
    // Guarded by null check for PIPE sequence item
    cp_pipe_gen : coverpoint pipe_seq_item_h.gen iff (pipe_seq_item_h != null) {
      bins gen1 = {pipe_agent_pkg::GEN1};
      bins gen2 = {pipe_agent_pkg::GEN2};
      bins gen3 = {pipe_agent_pkg::GEN3};
      bins gen4 = {pipe_agent_pkg::GEN4};
      bins gen5 = {pipe_agent_pkg::GEN5};
    }

  endgroup : pcie_env_cov

  // Standard UVM Methods:
  extern function new(string name = "pcie_coverage_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  extern function void write_lpif_received(lpif_seq_item lpif_seq_item_h);
  extern function void write_pipe_received(pipe_seq_item pipe_seq_item_h);

endclass: pcie_coverage_monitor

function pcie_coverage_monitor::new(string name = "pcie_coverage_monitor", uvm_component parent = null);
  super.new(name, parent);
  pcie_env_cov = new();
endfunction

function void pcie_coverage_monitor::build_phase(uvm_phase phase);
  `uvm_info(get_name(), "Enter pcie_coverage_monitor build_phase", UVM_MEDIUM)
  lpif_export_sent = new("lpif_export_sent", this);
  lpif_export_received = new("lpif_export_received", this);
  pipe_export_sent = new("pipe_export_sent", this);
  pipe_export_received = new("pipe_export_received", this);
  lpif_fifo = new("lpif_fifo", this);
  pipe_fifo = new("pipe_fifo", this);
  `uvm_info(get_name(), "Exit pcie_coverage_monitor build_phase", UVM_MEDIUM)
endfunction:build_phase

function void pcie_coverage_monitor::connect_phase(uvm_phase phase);
  lpif_export_sent.connect(lpif_fifo.analysis_export);
  pipe_export_sent.connect(pipe_fifo.analysis_export);
endfunction:connect_phase

function void pcie_coverage_monitor::report_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("PCIe Environment Coverage: %.2f%%", 
            pcie_env_cov.get_coverage()), UVM_LOW)
endfunction:report_phase

// Sample coverage when LPIF transaction is received
function void pcie_coverage_monitor::write_lpif_received(lpif_seq_item lpif_seq_item_h);
  this.lpif_seq_item_h = lpif_seq_item_h;
  pcie_env_cov.sample();
endfunction:write_lpif_received

// Sample coverage when PIPE transaction is received
function void pcie_coverage_monitor::write_pipe_received(pipe_seq_item pipe_seq_item_h);
  this.pipe_seq_item_h = pipe_seq_item_h;
  pcie_env_cov.sample();
endfunction:write_pipe_received