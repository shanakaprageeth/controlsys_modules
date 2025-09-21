# Control System FPGA Modules

This repository contains Verilog FPGA modules for control systems including BLDC motor control, SPI communication, digital filters, encoder interfaces, and motor drivers. The modules are designed for use with Intel/Altera (Cyclone 5) and Xilinx (Spartan 6) FPGAs for active suspension controllers.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Setup
- Install Icarus Verilog for simulation and syntax checking:
  - `sudo apt-get update && sudo apt-get install -y iverilog gtkwave`
- Install any required FPGA vendor tools (Intel Quartus Prime or Xilinx Vivado) for actual synthesis and implementation.

### Validation and Testing
- Validate module syntax: `iverilog -t null <module_name>.v`
- Compile for simulation: `iverilog -o <output_name> <module_name>.v`  
- Run simulation: `./<output_name>`
- Individual module compilation takes under 0.01 seconds. NEVER CANCEL.
- Batch compilation of all working modules takes under 0.02 seconds. NEVER CANCEL.
- Running simulations takes under 0.1 seconds. NEVER CANCEL.

### Test the Complete Build Process
```bash
# Test all working modules (takes ~0.1 seconds total)
for module in bldc_commutation.v dac712_interface.v encoder_interface.v filter_basic_fixed.v quadrature_encoder_interface.v pwm_out.v spi_slave.v uart.v movo_Interface.v; do
    iverilog -t null "$module" && echo "$module: PASS" || echo "$module: FAIL"
done

# Test with testbench (BLDC motor commutation)
iverilog -o test_bldc bldc_commutation.v bldc_commutation_tb.v
./test_bldc
```

### Module Status
**Working Modules (9/11):**
- `bldc_commutation.v` - BLDC trapezoidal commutation for Nippon Pulse S250T Linear Motor
- `dac712_interface.v` - Interface for DAC712 digital-to-analog converter IC
- `encoder_interface.v` - Interface for linear encoder (Renishaw LM10)
- `filter_basic_fixed.v` - Simple fixed-point filter
- `quadrature_encoder_interface.v` - Quadrature encoder interface for linear encoder
- `pwm_out.v` - PWM output for DC motor control (use PLL if needed)
- `spi_slave.v` - SPI slave module for ARM mbed microcontroller interface
- `uart.v` - UART communication module (use PLL if needed)
- `movo_Interface.v` - Interface to send current commands to Servoland SVF motor controllers

**Known Broken Modules (2/11):**
- `spi_master.v` - FAILS: Duplicate signal declaration (`sclk_spi_drive` declared as both input and output)
- `filter_float_IIR_buttorworth.v` - FAILS: Missing dependencies (`float_multi`, `float_add_sub` modules)

### Available Test Infrastructure
- `bldc_commutation_tb.v` - Testbench for BLDC commutation module
- `run_simulation.do` - ModelSim/QuestaSim simulation script (requires commercial tools)
- `test.mpf` - ModelSim project file (requires commercial tools)

## Validation Scenarios

Always run these validation steps after making changes:

### Basic Syntax Validation
```bash
# Quick syntax check for all working modules (< 0.1 seconds)
cd /path/to/repository
for module in bldc_commutation.v dac712_interface.v encoder_interface.v filter_basic_fixed.v quadrature_encoder_interface.v pwm_out.v spi_slave.v uart.v movo_Interface.v; do
    iverilog -t null "$module"
done
```

### Simulation Validation  
```bash
# Compile and run BLDC testbench (< 0.1 seconds total)
iverilog -o test_bldc bldc_commutation.v bldc_commutation_tb.v
./test_bldc
# Expected output: "bldc_commutation_tb.v:56: $finish called at 85000 (1ps)"
```

### Hardware Interface Safety Warnings
- **CRITICAL**: Always test controller and actuator circuits for safety before connecting to actual hardware
- **IMPORTANT**: Verify hall sensor arrangement for your specific motor before using BLDC modules
- **WARNING**: Carefully assign pins according to your circuit diagram
- **CAUTION**: These modules interface with high-power motor controllers - incorrect wiring can damage equipment

## Common Tasks

### Synthesis for FPGA
- **Intel/Altera**: Use Quartus Prime (install separately) for Cyclone 5 targets
- **Xilinx**: Use Vivado (install separately) for Spartan 6 targets  
- Pin assignments must be configured according to hardware circuit diagrams
- Synthesis and implementation timing varies by FPGA size and design complexity

### Hardware Dependencies
Modules are designed to interface with:
- BLDC Linear or Rotary motors with controllers (tested: Nippon Pulse S250T)
- Servoland SVF current control motor drivers
- DAC712 IC for digital-to-analog conversion
- SPI slave ICs such as ADXL345 accelerometer
- SPI master microcontrollers such as ARM mbed
- DC motors
- Linear encoders (Renishaw LM10)

### Project Structure
```
/
├── README.md                              # Project overview and setup instructions
├── LICENSE                               # MIT License
├── bldc_commutation.v                    # BLDC motor commutation module (WORKING)
├── bldc_commutation_tb.v                 # BLDC testbench (WORKING)
├── dac712_interface.v                    # DAC712 interface (WORKING)
├── encoder_interface.v                   # Encoder interface (WORKING)
├── filter_basic_fixed.v                  # Basic fixed-point filter (WORKING)
├── filter_float_IIR_buttorworth.v        # Float Butterworth filter (BROKEN - missing deps)
├── movo_Interface.v                      # Servoland motor interface (WORKING)
├── pwm_out.v                            # PWM output (WORKING)
├── quadrature_encoder_interface.v        # Quadrature encoder (WORKING)
├── run_simulation.do                     # ModelSim script
├── spi_master.v                         # SPI master (BROKEN - signal conflict)
├── spi_slave.v                          # SPI slave (WORKING)
├── test.mpf                             # ModelSim project file
└── uart.v                               # UART communication (WORKING)
```

### Timing Expectations
- **Module syntax checking**: < 0.01 seconds per module. NEVER CANCEL.
- **Module compilation**: < 0.01 seconds per module. NEVER CANCEL.  
- **Simulation runs**: < 0.1 seconds for typical testbenches. NEVER CANCEL.
- **Batch validation**: < 0.2 seconds for all working modules. NEVER CANCEL.
- **FPGA synthesis**: Varies greatly (minutes to hours) depending on target device and design complexity.

## Error Reference

### Common Compilation Errors
- **"Unknown module type"**: Missing dependency modules (e.g., `float_multi` in Butterworth filter)
- **"has already been declared"**: Duplicate signal declarations (e.g., `spi_master.v`)
- **"syntax error"**: Check for trailing characters or malformed Verilog syntax

### Working Around Broken Modules
- `spi_master.v`: Fix duplicate `sclk_spi_drive` declaration before use
- `filter_float_IIR_buttorworth.v`: Requires external floating-point IP cores from FPGA vendor

Always validate any changes to Verilog modules by running syntax checks and simulations before committing to ensure hardware compatibility and safety.