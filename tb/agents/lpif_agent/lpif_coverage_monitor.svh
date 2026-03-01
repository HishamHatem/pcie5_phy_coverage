`uvm_analysis_imp_decl(_sent)
`uvm_analysis_imp_decl(_received)

class lpif_coverage_monitor extends uvm_component;

  `uvm_component_utils(lpif_coverage_monitor)
  
  lpif_seq_item lpif_seq_item_h;
  bit is_sent;  // Track direction: 1=TX path, 0=RX path

  uvm_analysis_imp_sent #(lpif_seq_item, lpif_coverage_monitor) analysis_export_sent;
  uvm_analysis_imp_received #(lpif_seq_item, lpif_coverage_monitor) analysis_export_received;

  //=============================================================================================
  // LPIF Feature Coverage Covergroup
  // Covers: Reset, Link Up, Speed Change, Data Transfer (TX/RX)
  //=============================================================================================
  covergroup lpif_feature_cov;
    
    //========== Feature 1 & 2: Reset and Link Up Coverage ==========
    cp_operation : coverpoint lpif_seq_item_h.lpif_operation {
      bins link_up       = {LINK_UP};        // Feature: Link Up
      bins link_reset    = {LINK_RESET};     // Feature: Reset
      bins tlp_transfer  = {TLP_TRANSFER};   // Feature: Data Transfer
      bins dllp_transfer = {DLLP_TRANSFER};  // Feature: Data Transfer
      //bins enter_retrain = {ENTER_RETRAIN};
      bins send_data     = {SEND_DATA};
      bins reset_to_up_to_tlp = (LINK_RESET => LINK_UP => TLP_TRANSFER);
    }
    //state coverage
    cp_state : coverpoint lpif_seq_item_h.current_state {
      bins active    = {ACTIVE};
      bins reset     = {RESET};
      bins retrain   = {RETRAIN};
      bins cold_boot = (RESET => ACTIVE);
      bins recovery  = (RETRAIN => ACTIVE);
      bins flap      = (ACTIVE => ACTIVE);
    }

    //========== Feature 3: Speed Change Coverage ==========
    cp_speed_mode : coverpoint lpif_seq_item_h.speed_mode {
      bins gen1 = {LPIF_GEN1};
      bins gen2 = {LPIF_GEN2};
      bins gen3 = {LPIF_GEN3};
      bins gen4 = {LPIF_GEN4};
      bins gen5 = {LPIF_GEN5};
    }

    //========== Feature 5: Data Transfer - Direction Coverage ==========
    cp_direction : coverpoint is_sent {
      bins tx_path = {1'b1};  // Data sent (TX path)
      bins rx_path = {1'b0};  // Data received (RX path)
    }

    //========== Feature 5: Data Transfer - TLP Size Coverage ==========
    cp_tlp_size : coverpoint lpif_seq_item_h.tlp.size() 
                  iff (lpif_seq_item_h.lpif_operation == TLP_TRANSFER) {
      bins zero        = {0};          // Zero-length TLPs (if allowed by spec)
      bins min_size    = {[12:15]};   // Minimum TLP size
      bins is_small       = {[16:63]};   // Small TLPs
      bins is_medium      = {[64:127]};  // Medium TLPs
      bins is_large       = {[128:255]}; // Large TLPs
      // bins max_size    = {[256:400]}; // Maximum TLP size
    }

    //========== Cross Coverage ==========
    
    // Data Transfer at different speeds
    cx_operation_x_speed : cross cp_operation, cp_speed_mode ;

    // Data Transfer direction (TX vs RX)
    cx_data_x_direction : cross cp_operation, cp_direction {
      bins tlp_tx  = binsof(cp_operation.tlp_transfer) && binsof(cp_direction.tx_path);
      bins tlp_rx  = binsof(cp_operation.tlp_transfer) && binsof(cp_direction.rx_path);
      bins dllp_tx = binsof(cp_operation.dllp_transfer) && binsof(cp_direction.tx_path);
      bins dllp_rx = binsof(cp_operation.dllp_transfer) && binsof(cp_direction.rx_path);
    }

    // TLP size at different speeds
    cx_tlp_size_x_speed : cross cp_tlp_size, cp_speed_mode;

    //cross all of them
    cx_all : cross cp_operation, cp_speed_mode, cp_tlp_size;

    //cross speed with senario
     cx_senario_speed : cross  cp_operation ,cp_speed_mode
      {
        bins reset_to_up_to_tlp_gen1 = binsof(cp_operation.reset_to_up_to_tlp) && binsof(cp_speed_mode.gen1);
        bins reset_to_up_to_tlp_gen2 = binsof(cp_operation.reset_to_up_to_tlp) && binsof(cp_speed_mode.gen2);
        bins reset_to_up_to_tlp_gen3 = binsof(cp_operation.reset_to_up_to_tlp) && binsof(cp_speed_mode.gen3);
        bins reset_to_up_to_tlp_gen4 = binsof(cp_operation.reset_to_up_to_tlp) && binsof(cp_speed_mode.gen4);
        bins reset_to_up_to_tlp_gen5 = binsof(cp_operation.reset_to_up_to_tlp) && binsof(cp_speed_mode.gen5);
      }

  endgroup : lpif_feature_cov

  //=============================================================================================
  // UVM Methods
  //=============================================================================================
  function new(string name = "lpif_coverage_monitor", uvm_component parent = null);
    super.new(name, parent);
    lpif_feature_cov = new();
  endfunction

  function void build_phase(uvm_phase phase);
    `uvm_info(get_name(), "Enter lpif_coverage_monitor build_phase", UVM_MEDIUM)
    analysis_export_sent = new("analysis_export_sent", this);
    analysis_export_received = new("analysis_export_received", this);
    `uvm_info(get_name(), "Exit lpif_coverage_monitor build_phase", UVM_MEDIUM)
  endfunction

  // TX Path - Data sent from DUT
  function void write_sent(lpif_seq_item lpif_seq_item_h);
    this.lpif_seq_item_h = lpif_seq_item_h;
    this.is_sent = 1'b1;  // TX direction
    lpif_feature_cov.sample();
  endfunction

  // RX Path - Data received by DUT
  function void write_received(lpif_seq_item lpif_seq_item_h);
    this.lpif_seq_item_h = lpif_seq_item_h;
    this.is_sent = 1'b0;  // RX direction
    lpif_feature_cov.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("LPIF Feature Coverage: %.2f%%", 
              lpif_feature_cov.get_coverage()), UVM_LOW)
  endfunction: report_phase

endclass