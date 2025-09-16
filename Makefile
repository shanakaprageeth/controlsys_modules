# Makefile for ControlSys Modules Testing
# Uses Icarus Verilog for simulation and GTKWave for waveform viewing

# Compiler and simulation tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Directories
SRC_DIR = .
TEST_DIR = tests
TB_DIR = $(TEST_DIR)/testbenches
REPORT_DIR = $(TEST_DIR)/reports
WAVE_DIR = $(TEST_DIR)/waveforms

# Create necessary directories
$(shell mkdir -p $(TB_DIR) $(REPORT_DIR) $(WAVE_DIR))

# Source files
MODULES = bldc_commutation pwm_out spi_master spi_slave uart \
          filter_basic_fixed filter_float_IIR_buttorworth \
          encoder_interface quadrature_encoder_interface \
          dac712_interface movo_Interface

# Test targets
TEST_TARGETS = $(addprefix test_, $(MODULES))
WAVE_TARGETS = $(addprefix wave_, $(MODULES))

# Default target
.PHONY: all clean test help list-modules
all: test

# Help target
help:
	@echo "ControlSys Modules Testing Framework"
	@echo "===================================="
	@echo ""
	@echo "Available targets:"
	@echo "  all           - Run all tests"
	@echo "  test          - Run all tests"
	@echo "  test_<module> - Run test for specific module"
	@echo "  wave_<module> - View waveforms for specific module"
	@echo "  clean         - Clean generated files"
	@echo "  list-modules  - List all available modules"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Available modules:"
	@echo "  $(MODULES)"

# List modules target
list-modules:
	@echo "Available modules for testing:"
	@for module in $(MODULES); do echo "  - $$module"; done

# Test all modules
test: $(TEST_TARGETS)
	@echo "All tests completed successfully!"
	@echo "Test reports available in $(REPORT_DIR)/"

# Individual module test targets
test_bldc_commutation: $(WAVE_DIR)/bldc_commutation.vcd
	@echo "✓ BLDC Commutation test completed"

test_pwm_out: $(WAVE_DIR)/pwm_out.vcd
	@echo "✓ PWM Output test completed"

test_spi_master: $(WAVE_DIR)/spi_master.vcd
	@echo "✓ SPI Master test completed"

test_spi_slave: $(WAVE_DIR)/spi_slave.vcd
	@echo "✓ SPI Slave test completed"

test_uart: $(WAVE_DIR)/uart.vcd
	@echo "✓ UART test completed"

test_filter_basic_fixed: $(WAVE_DIR)/filter_basic_fixed.vcd
	@echo "✓ Basic Fixed Filter test completed"

test_filter_float_IIR_buttorworth: $(WAVE_DIR)/filter_float_IIR_buttorworth.vcd
	@echo "✓ Float IIR Butterworth Filter test completed"

test_encoder_interface: $(WAVE_DIR)/encoder_interface.vcd
	@echo "✓ Encoder Interface test completed"

test_quadrature_encoder_interface: $(WAVE_DIR)/quadrature_encoder_interface.vcd
	@echo "✓ Quadrature Encoder Interface test completed"

test_dac712_interface: $(WAVE_DIR)/dac712_interface.vcd
	@echo "✓ DAC712 Interface test completed"

test_movo_Interface: $(WAVE_DIR)/movo_Interface.vcd
	@echo "✓ Movo Interface test completed"

# VCD file generation rules
$(WAVE_DIR)/bldc_commutation.vcd: $(SRC_DIR)/bldc_commutation.v $(TB_DIR)/bldc_commutation_tb.v
	@echo "Running BLDC Commutation test..."
	@$(IVERILOG) -o $(WAVE_DIR)/bldc_commutation.out $^
	@cd $(WAVE_DIR) && $(VVP) bldc_commutation.out

$(WAVE_DIR)/pwm_out.vcd: $(SRC_DIR)/pwm_out.v $(TB_DIR)/pwm_out_tb.v
	@echo "Running PWM Output test..."
	@$(IVERILOG) -o $(WAVE_DIR)/pwm_out.out $^
	@cd $(WAVE_DIR) && $(VVP) pwm_out.out

$(WAVE_DIR)/spi_master.vcd: $(SRC_DIR)/spi_master.v $(TB_DIR)/spi_master_tb.v
	@echo "Running SPI Master test..."
	@$(IVERILOG) -o $(WAVE_DIR)/spi_master.out $^
	@cd $(WAVE_DIR) && $(VVP) spi_master.out

$(WAVE_DIR)/spi_slave.vcd: $(SRC_DIR)/spi_slave.v $(TB_DIR)/spi_slave_tb.v
	@echo "Running SPI Slave test..."
	@$(IVERILOG) -o $(WAVE_DIR)/spi_slave.out $^
	@cd $(WAVE_DIR) && $(VVP) spi_slave.out

$(WAVE_DIR)/uart.vcd: $(SRC_DIR)/uart.v $(TB_DIR)/uart_tb.v
	@echo "Running UART test..."
	@$(IVERILOG) -o $(WAVE_DIR)/uart.out $^
	@cd $(WAVE_DIR) && $(VVP) uart.out

$(WAVE_DIR)/filter_basic_fixed.vcd: $(SRC_DIR)/filter_basic_fixed.v $(TB_DIR)/filter_basic_fixed_tb.v
	@echo "Running Basic Fixed Filter test..."
	@$(IVERILOG) -o $(WAVE_DIR)/filter_basic_fixed.out $^
	@cd $(WAVE_DIR) && $(VVP) filter_basic_fixed.out

$(WAVE_DIR)/filter_float_IIR_buttorworth.vcd: $(SRC_DIR)/filter_float_IIR_buttorworth.v $(TB_DIR)/filter_float_IIR_buttorworth_tb.v
	@echo "Running Float IIR Butterworth Filter test..."
	@$(IVERILOG) -o $(WAVE_DIR)/filter_float_IIR_buttorworth.out $^
	@cd $(WAVE_DIR) && $(VVP) filter_float_IIR_buttorworth.out

$(WAVE_DIR)/encoder_interface.vcd: $(SRC_DIR)/encoder_interface.v $(TB_DIR)/encoder_interface_tb.v
	@echo "Running Encoder Interface test..."
	@$(IVERILOG) -o $(WAVE_DIR)/encoder_interface.out $^
	@cd $(WAVE_DIR) && $(VVP) encoder_interface.out

$(WAVE_DIR)/quadrature_encoder_interface.vcd: $(SRC_DIR)/quadrature_encoder_interface.v $(TB_DIR)/quadrature_encoder_interface_tb.v
	@echo "Running Quadrature Encoder Interface test..."
	@$(IVERILOG) -o $(WAVE_DIR)/quadrature_encoder_interface.out $^
	@cd $(WAVE_DIR) && $(VVP) quadrature_encoder_interface.out

$(WAVE_DIR)/dac712_interface.vcd: $(SRC_DIR)/dac712_interface.v $(TB_DIR)/dac712_interface_tb.v
	@echo "Running DAC712 Interface test..."
	@$(IVERILOG) -o $(WAVE_DIR)/dac712_interface.out $^
	@cd $(WAVE_DIR) && $(VVP) dac712_interface.out

$(WAVE_DIR)/movo_Interface.vcd: $(SRC_DIR)/movo_Interface.v $(TB_DIR)/movo_Interface_tb.v
	@echo "Running Movo Interface test..."
	@$(IVERILOG) -o $(WAVE_DIR)/movo_Interface.out $^
	@cd $(WAVE_DIR) && $(VVP) movo_Interface.out

# Waveform viewing targets
wave_bldc_commutation: $(WAVE_DIR)/bldc_commutation.vcd
	@echo "Opening BLDC Commutation waveforms..."
	@$(GTKWAVE) $< &

wave_pwm_out: $(WAVE_DIR)/pwm_out.vcd
	@echo "Opening PWM Output waveforms..."
	@$(GTKWAVE) $< &

wave_spi_master: $(WAVE_DIR)/spi_master.vcd
	@echo "Opening SPI Master waveforms..."
	@$(GTKWAVE) $< &

wave_spi_slave: $(WAVE_DIR)/spi_slave.vcd
	@echo "Opening SPI Slave waveforms..."
	@$(GTKWAVE) $< &

wave_uart: $(WAVE_DIR)/uart.vcd
	@echo "Opening UART waveforms..."
	@$(GTKWAVE) $< &

wave_filter_basic_fixed: $(WAVE_DIR)/filter_basic_fixed.vcd
	@echo "Opening Basic Fixed Filter waveforms..."
	@$(GTKWAVE) $< &

wave_filter_float_IIR_buttorworth: $(WAVE_DIR)/filter_float_IIR_buttorworth.vcd
	@echo "Opening Float IIR Butterworth Filter waveforms..."
	@$(GTKWAVE) $< &

wave_encoder_interface: $(WAVE_DIR)/encoder_interface.vcd
	@echo "Opening Encoder Interface waveforms..."
	@$(GTKWAVE) $< &

wave_quadrature_encoder_interface: $(WAVE_DIR)/quadrature_encoder_interface.vcd
	@echo "Opening Quadrature Encoder Interface waveforms..."
	@$(GTKWAVE) $< &

wave_dac712_interface: $(WAVE_DIR)/dac712_interface.vcd
	@echo "Opening DAC712 Interface waveforms..."
	@$(GTKWAVE) $< &

wave_movo_Interface: $(WAVE_DIR)/movo_Interface.vcd
	@echo "Opening Movo Interface waveforms..."
	@$(GTKWAVE) $< &

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf $(WAVE_DIR)/*.vcd $(WAVE_DIR)/*.out $(REPORT_DIR)/*
	@rm -f *.vcd *.out bldc_test
	@echo "Clean completed."

.PHONY: $(TEST_TARGETS) $(WAVE_TARGETS)