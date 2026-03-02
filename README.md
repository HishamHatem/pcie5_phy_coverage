# pcie5_phy
PCIE 5.0 Graduation project (Verification Team)

## Getting Started

Navigate to the simulation directory:
```bash
cd tb/sim
```

## Build

Build the environment:
```bash
make build
```

## Run Simulation

### Without Coverage (GUI)
```bash
make run
```

### With Coverage (GUI)
```bash
make run_cov
```

### With Coverage (Batch Mode - No GUI)
```bash
make run_cov_batch
```

## Coverage Reports

### Generate Text Report
```bash
make cov_report_text    # Creates coverage_report.txt
```

### Generate HTML Report
```bash
make cov_report_html    # Creates coverage_html/index.html
```

### View Coverage in QuestaSim GUI
```bash
make cov_view
```

## Quick Test with Coverage
```bash
make clean
make build
make run_cov_batch
make cov_report_text
cat coverage_report.txt
```
