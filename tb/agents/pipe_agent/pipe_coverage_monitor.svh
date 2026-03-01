`uvm_analysis_imp_decl(_sent)
`uvm_analysis_imp_decl(_received)

class pipe_coverage_monitor extends uvm_component;

  `uvm_component_utils(pipe_coverage_monitor);

  pipe_seq_item pipe_seq_item_h;
  bit is_sent;  // Track direction: 1=TX path, 0=RX path

  uvm_analysis_imp_sent #(pipe_seq_item, pipe_coverage_monitor) analysis_export_sent;
  uvm_analysis_imp_received #(pipe_seq_item, pipe_coverage_monitor) analysis_export_received;

  //=============================================================================================
  // PIPE Feature Coverage Covergroup
  // Covers: Reset, Link Up, Speed Change, Equalization, Data Transfer (TX/RX)
  //=============================================================================================
  covergroup pipe_feature_cov;

    //========== Feature 1 & 2: Reset and Link Up Coverage ==========
    cp_operation : coverpoint pipe_seq_item_h.pipe_operation {
      bins tlp_transfer     = {TLP_TRANSFER};      // Feature: Data Transfer
      bins dllp_transfer    = {DLLP_TRANSFER};     // Feature: Data Transfer
      bins idle_data        = {IDLE_DATA_TRANSFER};
      bins link_up          = {LINK_UP};           // Feature: Link Up
      bins enter_recovery   = {ENTER_RECOVERY};
      bins speed_change     = {SPEED_CHANGE};      // Feature: Speed Change
      bins reset            = {RESET};             // Feature: Reset
      bins pclk_rate_change = {PCLK_RATE_CHANGE};
      bins width_change     = {WIDTH_CHANGE};
      bins send_ts          = {SEND_TS};
      bins send_tses        = {SEND_TSES};
      bins send_eios        = {SEND_EIOS};
      bins send_eieos       = {SEND_EIEOS};
      bins set_gen          = {SET_GEN};
      bins send_data        = {SEND_DATA};
      bins check_eq_preset  = {CHECK_EQ_PRESET_APPLIED};  // Feature: Equalization
      bins set_eq_param     = {SET_EQ_PARAM};             // Feature: Equalization
      bins assert_eval_fb   = {ASSERT_EVAL_FEEDBACK_CHANGED};
    }

    //========== Feature 3: Speed Change - Generation Coverage ==========
    cp_gen : coverpoint pipe_seq_item_h.gen {
      bins gen1 = {GEN1};
      bins gen2 = {GEN2};
      bins gen3 = {GEN3};
      bins gen4 = {GEN4};
      bins gen5 = {GEN5};
    }

    //========== Feature 3: Speed Change - PCLK Rate Coverage ==========
    cp_pclk_rate : coverpoint pipe_seq_item_h.pclk_rate {
      bins pclk_62   = {PCLK_62};
      bins pclk_125  = {PCLK_125};
      bins pclk_250  = {PCLK_250};
      bins pclk_500  = {PCLK_500};
      bins pclk_1000 = {PCLK_1000};
      bins pclk_2000 = {PCLK_2000};
      bins pclk_4000 = {PCLK_4000};
    }

    //========== Feature 3: Speed Change - Width Coverage ==========
    cp_width : coverpoint pipe_seq_item_h.pipe_width {
      bins width_8  = {PIPE_WIDTH_8_BIT};
      bins width_16 = {PIPE_WIDTH_16_BIT};
      bins width_32 = {PIPE_WIDTH_32_BIT};
    }

    //========== Feature 4: Equalization - TS Type Coverage ==========
    cp_ts_type : coverpoint pipe_seq_item_h.ts_sent.ts_type 
                 iff (pipe_seq_item_h.pipe_operation == SEND_TS || 
                      pipe_seq_item_h.pipe_operation == SEND_TSES) {
      bins ts1 = {TS1};
      bins ts2 = {TS2};
    }

    //========== Feature 4: Equalization - Speed Change Bit ==========
    cp_speed_change_bit : coverpoint pipe_seq_item_h.ts_sent.speed_change
                          iff (pipe_seq_item_h.pipe_operation == SEND_TS || 
                               pipe_seq_item_h.pipe_operation == SEND_TSES) {
      bins no_speed_change = {1'b0};
      bins speed_change    = {1'b1};
    }

    //========== Feature 4: Equalization - RX Preset Hint Coverage ==========
    cp_rx_preset_hint : coverpoint pipe_seq_item_h.ts_sent.rx_preset_hint
                        iff (pipe_seq_item_h.pipe_operation == SEND_TS || 
                             pipe_seq_item_h.pipe_operation == SEND_TSES) {
      bins preset[8] = {[0:7]};  // All 8 preset values
    }

    //========== Feature 4: Equalization - TX Preset Coverage ==========
    cp_tx_preset : coverpoint pipe_seq_item_h.ts_sent.tx_preset
                   iff (pipe_seq_item_h.pipe_operation == SEND_TS || 
                        pipe_seq_item_h.pipe_operation == SEND_TSES) {
      bins preset[11] = {[0:10]};  // P0-P10 presets
      illegal_bins reserved = {[11:15]};
    }

    //========== Feature 4: Equalization - EC (Equalization Command) ==========
    cp_eq_command : coverpoint pipe_seq_item_h.ts_sent.ec
                    iff (pipe_seq_item_h.pipe_operation == SEND_TS || 
                         pipe_seq_item_h.pipe_operation == SEND_TSES) {
      bins ec_00 = {2'b00};  // No equalization
      bins ec_01 = {2'b01};  // Phase 2/3
      bins ec_10 = {2'b10};  // Phase 2/3
      bins ec_11 = {2'b11};  // Phase 2/3
    }

    //========== Feature 4: Equalization - Cursor Coefficients ==========
    cp_pre_cursor : coverpoint pipe_seq_item_h.ts_sent.pre_cursor
                    iff (pipe_seq_item_h.pipe_operation == SEND_TS) {
      bins zero     = {0};
      bins low      = {[1:10]};
      bins mid      = {[11:20]};
      bins high     = {[21:63]};
    }

    cp_cursor : coverpoint pipe_seq_item_h.ts_sent.cursor
                iff (pipe_seq_item_h.pipe_operation == SEND_TS) {
      bins low  = {[0:20]};
      bins mid  = {[21:40]};
      bins high = {[41:63]};
    }

    cp_post_cursor : coverpoint pipe_seq_item_h.ts_sent.post_cursor
                     iff (pipe_seq_item_h.pipe_operation == SEND_TS) {
      bins zero = {0};
      bins low  = {[1:10]};
      bins mid  = {[11:20]};
      bins high = {[21:63]};
    }

    //========== Feature 5: Data Transfer - Direction Coverage ==========
    cp_direction : coverpoint is_sent {
      bins tx_path = {1'b1};
      bins rx_path = {1'b0};
    }

    //========== Feature 5: Data Transfer - TLP Size Coverage ==========
    cp_tlp_size : coverpoint pipe_seq_item_h.tlp.size() 
                  iff (pipe_seq_item_h.pipe_operation == TLP_TRANSFER) {
      bins min_size  = {[12:15]};
      bins is_small  = {[16:63]};
      bins is_medium = {[64:127]};
      bins is_large  = {[128:255]};
      bins max_size  = {[256:400]};
    }

    //========== Cross Coverage ==========
    
    // Speed change across generations
    cx_speed_change_x_gen : cross cp_operation, cp_gen {
      bins speed_change_to_gen2 = binsof(cp_operation.speed_change) && binsof(cp_gen.gen2);
      bins speed_change_to_gen3 = binsof(cp_operation.speed_change) && binsof(cp_gen.gen3);
      bins speed_change_to_gen4 = binsof(cp_operation.speed_change) && binsof(cp_gen.gen4);
      bins speed_change_to_gen5 = binsof(cp_operation.speed_change) && binsof(cp_gen.gen5);
    }

    // Equalization at high generations (Gen3+)
    cx_eq_x_gen : cross cp_eq_command, cp_gen {
      bins eq_at_gen3 = binsof(cp_gen.gen3);
      bins eq_at_gen4 = binsof(cp_gen.gen4);
      bins eq_at_gen5 = binsof(cp_gen.gen5);
      ignore_bins low_gen = binsof(cp_gen.gen1) || binsof(cp_gen.gen2);
    }

    // Data transfer at different generations
    cx_data_x_gen : cross cp_operation, cp_gen {
      bins tlp_at_gen1 = binsof(cp_operation.tlp_transfer) && binsof(cp_gen.gen1);
      bins tlp_at_gen2 = binsof(cp_operation.tlp_transfer) && binsof(cp_gen.gen2);
      bins tlp_at_gen3 = binsof(cp_operation.tlp_transfer) && binsof(cp_gen.gen3);
      bins tlp_at_gen4 = binsof(cp_operation.tlp_transfer) && binsof(cp_gen.gen4);
      bins tlp_at_gen5 = binsof(cp_operation.tlp_transfer) && binsof(cp_gen.gen5);
      bins dllp_at_gen1 = binsof(cp_operation.dllp_transfer) && binsof(cp_gen.gen1);
      bins dllp_at_gen2 = binsof(cp_operation.dllp_transfer) && binsof(cp_gen.gen2);
      bins dllp_at_gen3 = binsof(cp_operation.dllp_transfer) && binsof(cp_gen.gen3);
      bins dllp_at_gen4 = binsof(cp_operation.dllp_transfer) && binsof(cp_gen.gen4);
      bins dllp_at_gen5 = binsof(cp_operation.dllp_transfer) && binsof(cp_gen.gen5);    
    }

    // Data transfer direction
    cx_data_x_direction : cross cp_operation, cp_direction {
      bins tlp_tx  = binsof(cp_operation.tlp_transfer) && binsof(cp_direction.tx_path);
      bins tlp_rx  = binsof(cp_operation.tlp_transfer) && binsof(cp_direction.rx_path);
      bins dllp_tx = binsof(cp_operation.dllp_transfer) && binsof(cp_direction.tx_path);
      bins dllp_rx = binsof(cp_operation.dllp_transfer) && binsof(cp_direction.rx_path);
    }

    // Data transfer at different widths
    cx_data_x_width : cross cp_operation, cp_width {
      bins tlp_width_8  = binsof(cp_operation.tlp_transfer) && binsof(cp_width.width_8);
      bins tlp_width_16 = binsof(cp_operation.tlp_transfer) && binsof(cp_width.width_16);
      bins tlp_width_32 = binsof(cp_operation.tlp_transfer) && binsof(cp_width.width_32);
      bins dllp_width_8  = binsof(cp_operation.dllp_transfer) && binsof(cp_width.width_8);
      bins dllp_width_16 = binsof(cp_operation.dllp_transfer) && binsof(cp_width.width_16);
      bins dllp_width_32 = binsof(cp_operation.dllp_transfer) && binsof(cp_width.width_32);
    }

  endgroup : pipe_feature_cov

  //=============================================================================================
  // UVM Methods
  //=============================================================================================
  extern function new(string name = "pipe_coverage_monitor", uvm_component parent = null);
  extern function void report_phase(uvm_phase phase);
  extern function void build_phase(uvm_phase phase);
  extern function void write_sent(pipe_seq_item pipe_seq_item_h);
  extern function void write_received(pipe_seq_item pipe_seq_item_h);

endclass: pipe_coverage_monitor

function void pipe_coverage_monitor::write_sent(pipe_seq_item pipe_seq_item_h);
  this.pipe_seq_item_h = pipe_seq_item_h;
  this.is_sent = 1'b1;  // TX direction
  pipe_feature_cov.sample();
endfunction

function void pipe_coverage_monitor::write_received(pipe_seq_item pipe_seq_item_h);
  this.pipe_seq_item_h = pipe_seq_item_h;
  this.is_sent = 1'b0;  // RX direction
  pipe_feature_cov.sample();
endfunction

function void pipe_coverage_monitor::build_phase(uvm_phase phase);
  `uvm_info(get_name(), "Enter pipe_coverage_monitor build_phase", UVM_MEDIUM)
  analysis_export_sent = new("analysis_export_sent", this);
  analysis_export_received = new("analysis_export_received", this);
  `uvm_info(get_name(), "Exit pipe_coverage_monitor build_phase", UVM_MEDIUM)
endfunction  

function pipe_coverage_monitor::new(string name = "pipe_coverage_monitor", uvm_component parent = null);
  super.new(name, parent);
  pipe_feature_cov = new();
endfunction

function void pipe_coverage_monitor::report_phase(uvm_phase phase);
  `uvm_info(get_name(), $sformatf("PIPE Feature Coverage: %.2f%%", 
            pipe_feature_cov.get_coverage()), UVM_LOW)
endfunction: report_phase
