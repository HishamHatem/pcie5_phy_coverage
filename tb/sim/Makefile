#################################### Pathes #####################################
PIPE_ROOT_PATH 		  	= ../agents/pipe_agent
LPIF_ROOT_PATH 		  	= ../agents/lpif_agent
ENV_ROOT_PATH       	= ../env
SEQ_ROOT_PATH       	= ../sequences
TEST_ROOT_PATH      	= ../test
COMMON_ROOT_PATH    	= ..
UTILITY_ROOT_PATH    	= ../utility
TOP_ROOT_PATH       	= ../top

################################ Build Configurations ################################
IS_ENV_UPSTREAM   		= 1
PIPE_MAX_WIDTH 		    = 32
NUM_OF_LANES 			= 16
LPIF_BUS_WIDTH 			= 512

###################################### Includes ######################################
include ../common.mk
include ../agents/pipe_agent/pipe_agent.mk
include ../agents/lpif_agent/lpif_agent.mk
include ../env/pcie_env.mk
include ../sequences/pcie_seq.mk
include ../test/pcie_test.mk
include ../top/top.mk
include ../utility/utility.mk

################################ Available Virutal Seqeunces ################################
# dummy_vseq
# reset_vseq
# link_up_vseq
# enter_recovery_vseq
# data_exchange_vseq

#################################### Run Configurations #####################################
TEST								= pcie_test
DEF_SEQ									= reset_vseq,link_up_vseq
# SEQ									= reset_vseq,dummy_vseq

#################################### Coverage Flags #####################################
VLOG_COV_OPTS = +cover=bcestf
VSIM_COV_OPTS = -coverage

#################################### Rules #####################################
build_pipe: 			COMMON_BUILD PIPE_BUILD_PACKAGE PIPE_BUILD_INTERFACES
build_lpif: 			COMMON_BUILD LPIF_BUILD_PACKAGE LPIF_BUILD_INTERFACES
build_agents: 			build_pipe build_lpif
build_seq:    			build_agents SEQ_BUILD
build_env:    			build_agents ENV_BUILD
build_test:    			build_agents build_env build_seq TEST_BUILD

build: COMMON_BUILD UTILITY_BUILD build_agents ENV_BUILD SEQ_BUILD TEST_BUILD TOP_BUILD
	@echo Project is built 
#################################### Run Without Coverage #####################################
run:
ifdef SEQ
	vsim -gui -do "wave.do" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${SEQ} -suppress 8887
else 
	vsim -gui -do "wave.do" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${DEF_SEQ} -suppress 8887
endif
run_design:
	vsim -novopt -do "design.do" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${DEF_SEQ} -suppress 8887 -suppress 12110

#################################### Run With Coverage #####################################
# Run with coverage (GUI mode)
run_cov:
ifdef SEQ
	vsim $(VSIM_COV_OPTS) -gui -do "wave.do" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${SEQ} -suppress 8887
else
	vsim $(VSIM_COV_OPTS) -gui -do "wave.do" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${DEF_SEQ} -suppress 8887
endif

# Run with coverage (batch mode - no GUI)
run_cov_batch:
ifdef SEQ
	vsim $(VSIM_COV_OPTS) -c -do "run -all; coverage save -onexit coverage.ucdb; quit" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${SEQ} -suppress 8887
else
	vsim $(VSIM_COV_OPTS) -c -do "run -all; coverage save -onexit coverage.ucdb; quit" hvl_top hdl_top +UVM_NO_RELNOTES +UVM_TESTNAME="$(TEST)" +VSEQ=${DEF_SEQ} -suppress 8887
endif
#################################### Coverage Reports #####################################
# Generate text coverage report
cov_report_text:
	vcover report -details coverage.ucdb > coverage_report.txt
	@echo "Text report saved to coverage_report.txt"

# Generate HTML coverage report
cov_report_html:
	vcover report -details -html coverage.ucdb -output coverage_html
	@echo "HTML report saved to coverage_html/index.html"

# View coverage in GUI
cov_view:
	vsim -viewcov coverage.ucdb &

#################################### Clean #####################################
clean:
	rm -rf work coverage.ucdb coverage_report.txt coverage_html

#################################### Help #####################################
help:
	@echo "Available targets:"
	@echo "  build          - Compile all files"
	@echo "  run            - Run simulation (GUI, no coverage)"
	@echo "  run_cov        - Run simulation (GUI, with coverage)"
	@echo "  run_cov_batch  - Run simulation (batch, with coverage)"
	@echo "  cov_report_text - Generate text coverage report"
	@echo "  cov_report_html - Generate HTML coverage report"
	@echo "  cov_view       - View coverage in GUI"
	@echo "  clean          - Remove work directory and coverage files"
