# controlsys_modules
This project contains some of the FPGA verilog modules I used for my active suspension controller. 
Includes following modules

- ** BLDC trapizoidal commutation module ** tested for Nippon Pulse S250T Linear Motor. 
                                            please test and edit hall arrangement before use.
- ** Movo interface ** To send current commands to Servoland SVF motor controllers
- ** DAC712 Interface ** Interface for DAC712 digital to analog controller IC
- ** Encoder interface ** Interface for linear encoder (Rehinshaw LM10)
- ** Quadrature Encoder interface ** Interface for linear encoder (Rehinshaw LM10)
- ** Filter Basic Fixed Point ** Simple fixed point filter
- ** Filter Float ButterWorth ** Second order Butterworth Filter
- ** PWM out ** pwm output without frequency control for DC motor(use PLL if needed.)
- ** SPI master ** spi master module used for ADXL345 accelrometer (use PLL if needed.)
- ** SPI slave ** spi master module used for ARM mbed microcontroller
- ** UART ** uart communication (use PLL if needed.)

## Getting Started

Please install Altera(now Intel) or Xilinix IDE to use these modules. Please be careful in pin assignment and interfacing circuits.

### Prerequisites

Altera(now Intel) or Xilinix IDE. 

Some modules are used to interface with following ICs.
BLDC Linear or Rotory motor with a controller.
Servoland SVF current control motor drivers.
DAC712 IC for digital to analog conversion.
SPI slave ICs such as ADXL345
SPI master microcontrollers such as ARM mbed microcontroller
DC motor

### Installing
Test controller and actuator circuits for safety.
Install Xilinix IDE or Altera(now Intel) IDE.
Use verilog to program the modules.
Assign pins according to your circuit digram.
Synthesis the design and load it to your FPGA.

## Running the tests

You can run tests either using simulations or interfacing the FPGA to a ARM mbed microcontroller through SPI.

