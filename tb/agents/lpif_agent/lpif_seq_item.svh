/******************************** Class Header ********************************************/
class lpif_seq_item extends uvm_sequence_item;
  `uvm_object_utils(lpif_seq_item)

  //  Group: Variables
  rand lpif_operation_t lpif_operation;
  rand tlp_t tlp;
  rand dllp_t dllp;
  rand lpif_speed_mode_t speed_mode;  // Current link speed (Gen1-Gen5)
  rand lpif_state_t current_state;   // Current state of the link (Active, Reset, Retrain, etc.)

  //  Group: Constraints
  constraint c1 {
    tlp.size() >= TLP_MIN_SIZE;
    tlp.size() <= TLP_MAX_SIZE;
    tlp.size()%4 == 2;
  };

  extern function new(string name = "lpif_seq_item");
  extern function void do_copy(uvm_object rhs);
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function string convert2string();
  extern function void do_print(uvm_printer printer);
  extern function lpif_seq_item_s to_struct();
  extern function void from_struct(lpif_seq_item_s lpif_seq_item_struct);
     
endclass: lpif_seq_item
/*******************************************************************************************/

/********************************* Class Implementation ************************************/

function lpif_seq_item::new(string name = "lpif_seq_item");
  super.new(name);
endfunction: new

function void lpif_seq_item::do_copy(uvm_object rhs);
  lpif_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end

  super.do_copy(rhs);
  // Copy over data members:
  lpif_operation = rhs_.lpif_operation;
  tlp = rhs_.tlp;
  dllp = rhs_.dllp;
  speed_mode = rhs_.speed_mode;
  current_state = rhs_.current_state;

endfunction:do_copy

function bit lpif_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  lpif_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end

  if (tlp.size() != rhs_.tlp.size()) begin
    return 0;
  end

  for (int i = 0; i < tlp.size(); i++) begin
    if (tlp[i] != rhs_.tlp[i] ) begin
      return 0;
    end
  end

  for (int i = 0; i < $size(dllp); i++) begin
    if (dllp[i] != rhs_.dllp[i] ) begin
      return 0;
    end
  end

  return super.do_compare(rhs, comparer) && 
         lpif_operation == rhs_.lpif_operation &&
         speed_mode == rhs_.speed_mode;
endfunction:do_compare

function string lpif_seq_item::convert2string();
  string s;

  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, "%s lpif_operation=%s speed_mode=%s tlp_size=%0d\n", 
           s, lpif_operation.name(), speed_mode.name(), tlp.size());
  return s;
endfunction:convert2string

function void lpif_seq_item::do_print(uvm_printer printer);
  printer.m_string = convert2string();
endfunction: do_print

function lpif_seq_item_s lpif_seq_item::to_struct ();
  lpif_seq_item_s lpif_struct;
  lpif_struct.tlp              = this.tlp;
  lpif_struct.dllp             = this.dllp;
  lpif_struct.lpif_operation   = this.lpif_operation;
  lpif_struct.speed_mode       = this.speed_mode;
  lpif_struct.current_state    = this.current_state;
  return lpif_struct;
endfunction: to_struct 

function void lpif_seq_item::from_struct (lpif_seq_item_s lpif_seq_item_struct);
  this.tlp                = lpif_seq_item_struct.tlp;
  this.dllp               = lpif_seq_item_struct.dllp;
  this.lpif_operation     = lpif_seq_item_struct.lpif_operation;
  this.speed_mode         = lpif_seq_item_struct.speed_mode;
  this.current_state      = lpif_seq_item_struct.current_state;
endfunction: from_struct 
