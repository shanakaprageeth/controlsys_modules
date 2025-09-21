# ControlSys Modules Testing Framework

This document describes the comprehensive testing framework implemented for the ControlSys Modules repository.

## Overview

The testing framework provides automated unit testing for all Verilog modules using industry-standard open-source tools. The framework includes:

- **Icarus Verilog**: Open-source Verilog simulator
- **GTKWave**: Waveform viewer for signal analysis
- **Make**: Build automation and test orchestration
- **GitHub Actions**: Continuous Integration pipeline

## Quick Start

### Prerequisites

```bash
# Install required tools (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y iverilog gtkwave make

# For other systems, refer to the official documentation:
# - Icarus Verilog: http://iverilog.icarus.com/
# - GTKWave: http://gtkwave.sourceforge.net/
```

### Running Tests

```bash
# Run all tests
make test

# Run specific module test
make test_bldc_commutation
make test_pwm_out
make test_filter_basic_fixed

# View waveforms for a specific module
make wave_bldc_commutation
make wave_pwm_out

# Get help
make help

# List available modules
make list-modules
```

### Using the Test Runner Script

```bash
# Run comprehensive test suite with colored output
./run_tests.sh
```

## Directory Structure

```
.
├── Makefile                      # Build automation and test orchestration
├── run_tests.sh                  # Test runner script with reporting
├── tests/                        # Test directory
│   ├── testbenches/              # Verilog testbenches
│   │   ├── bldc_commutation_tb.v
│   │   ├── pwm_out_tb.v
│   │   ├── filter_basic_fixed_tb.v
│   │   └── uart_tb.v
│   ├── waveforms/                # Generated VCD files
│   └── reports/                  # Test reports (future)
├── .github/workflows/            # CI/CD configuration
│   └── ci.yml                    # GitHub Actions workflow
└── *.v                          # Source Verilog modules
```

## Available Tests

### Implemented Tests

| Module | Test Coverage | Status |
|--------|--------------|--------|
| `bldc_commutation` | ✅ Hall state validation, error detection, enable/disable | Complete |
| `pwm_out` | ✅ Duty cycle verification, reset behavior, edge cases | Complete |
| `filter_basic_fixed` | ✅ Step response, impulse response, reset behavior | Complete |
| `uart` | ✅ Transmit/receive, enable/disable, reset behavior | Complete |

### Tests to be Added

| Module | Priority | Description |
|--------|----------|-------------|
| `spi_master` | High | SPI protocol compliance, data integrity |
| `spi_slave` | High | SPI slave response, data handling |
| `encoder_interface` | Medium | Encoder signal processing, position tracking |
| `quadrature_encoder_interface` | Medium | Quadrature decoding, direction detection |
| `dac712_interface` | Medium | DAC communication protocol |
| `movo_Interface` | Medium | Motor controller interface |
| `filter_float_IIR_buttorworth` | Low | IIR filter response, stability |

## Test Features

### Comprehensive Coverage

Each testbench includes:

- **Reset functionality testing**
- **Enable/disable behavior verification**
- **Edge case testing** (boundary conditions)
- **Functional verification** (core behavior)
- **Signal integrity checks**

### Waveform Generation

All tests generate VCD files for detailed signal analysis:

```bash
# Generate and view waveforms
make test_bldc_commutation
make wave_bldc_commutation  # Opens GTKWave
```

### Automated Reporting

The test framework provides:

- Pass/fail status for each test
- Detailed test logs
- Summary reports
- CI integration

## Continuous Integration

### GitHub Actions Workflow

The CI pipeline includes three jobs:

1. **Test Job**: Runs comprehensive test suite
2. **Lint Job**: Performs Verilog linting with Verilator
3. **Documentation Job**: Checks documentation completeness

### Workflow Triggers

- Push to main/master/develop branches
- Pull requests
- Manual workflow dispatch

### Artifacts

Test artifacts are automatically uploaded:
- VCD waveform files
- Test logs
- Reports (retention: 30 days)

## Writing New Tests

### Testbench Template

```verilog
`timescale 1ns / 1ps

module module_name_tb;

// Parameters
parameter CLK_PERIOD = 10;

// Signals
reg clk;
reg rst;
// ... other signals

// Test variables
integer test_count = 0;
integer pass_count = 0;
integer fail_count = 0;

// DUT instantiation
module_name uut (
    .clk(clk),
    .rst(rst),
    // ... other connections
);

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

// VCD dump
initial begin
    $dumpfile("module_name.vcd");
    $dumpvars(0, module_name_tb);
end

// Test tasks
task reset_system;
begin
    rst = 1;
    #(CLK_PERIOD * 3);
    rst = 0;
    #CLK_PERIOD;
end
endtask

// Main test sequence
initial begin
    clk = 0;
    $display("Module Test Suite");
    
    reset_system();
    
    // Add tests here
    
    // Summary
    $display("Tests: %d, Passed: %d, Failed: %d", 
             test_count, pass_count, fail_count);
    
    $finish;
end

endmodule
```

### Adding to Build System

1. Create testbench file in `tests/testbenches/`
2. Add module to `MODULES` list in `Makefile`
3. Add test to `TESTS` array in `run_tests.sh`

## Best Practices

### Test Design

- **Isolated tests**: Each test should be independent
- **Comprehensive coverage**: Test normal, edge, and error cases
- **Clear reporting**: Use descriptive messages and consistent formatting
- **Reasonable timing**: Use appropriate clock periods and delays

### Signal Integrity

- Generate VCD files for all tests
- Use meaningful signal names
- Document expected vs. actual behavior
- Verify timing relationships

### Documentation

- Comment complex test scenarios
- Explain expected behavior
- Document any known limitations
- Provide usage examples

## Performance Metrics

### Current Status

- **Total Modules**: 11
- **Tested Modules**: 4 (36%)
- **Test Coverage**: ~40% of critical functionality
- **CI/CD**: Fully automated
- **Documentation**: Comprehensive

### Goals

- [ ] 100% module coverage
- [ ] Advanced coverage analysis
- [ ] Performance benchmarking
- [ ] Formal verification integration
- [ ] Multi-platform testing

## Troubleshooting

### Common Issues

1. **VCD file not generated**: Check `$dumpfile` and `$dumpvars` calls
2. **Test timeout**: Increase simulation time or check for infinite loops
3. **Compilation errors**: Verify Verilog syntax and module interfaces
4. **Missing dependencies**: Ensure all required tools are installed

### Debug Commands

```bash
# Verbose compilation
iverilog -v -o test.out module.v testbench.v

# Run with detailed output
vvp -v test.out

# Check module syntax
iverilog -t null module.v
```

## Contributing

### Adding New Tests

1. Fork the repository
2. Create a feature branch
3. Add testbench using the template
4. Update Makefile and run_tests.sh
5. Verify tests pass locally
6. Submit pull request

### Improving Existing Tests

- Add more comprehensive test cases
- Improve test coverage
- Enhance error reporting
- Optimize test execution time

## Tools and Resources

### Open Source Tools Used

- [Icarus Verilog](http://iverilog.icarus.com/) - Verilog simulation
- [GTKWave](http://gtkwave.sourceforge.net/) - Waveform viewing
- [Verilator](https://www.veripool.org/verilator/) - Linting and analysis
- [GNU Make](https://www.gnu.org/software/make/) - Build automation

### Additional Resources

- [SystemVerilog Assertions](https://www.systemverilog.io/sva) - Advanced verification
- [UVM](https://www.accellera.org/downloads/standards/uvm) - Universal Verification Methodology
- [Formal Verification](https://www.symbiyosys.com/) - Mathematical proof techniques

---

For questions or support, please open an issue in the repository.