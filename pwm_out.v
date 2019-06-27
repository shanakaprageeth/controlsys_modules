`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: W A Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    09:51:37 01/17/2014 
// Design Name: PWM output module
// Module Name:    pwm_out 
// Project Name: 
// Target Devices: simple PWM output module for a DC motor. (no frequency control)
// Tool versions: 
// Description: 
//     simple PWM output module for a DC motor. (no frequency control)
// Dependencies: 
//     hardware : Motor driver circuit(amp), DC motor
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pwm_out(
clk,
pulse_pwm,
rst,
pwm_duty,
pwm_out
    );

//------------
// parameters
//-------------
parameter PWM_RESOLUTION = 8;
//------------
// input ports
//-------------
input 										clk;
input 										pulse_pwm;
input 										rst;
input 	[PWM_RESOLUTION-1:0]			pwm_duty;
//------------
// output ports
//-------------
output 	reg 			 	pwm_out = 0;
//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
reg [PWM_RESOLUTION-1:0] temp_reg = 0;
reg [PWM_RESOLUTION-1:0] count = 0;
//--------
// wires
//-------

always @ (posedge clk)
	begin
		if (rst)
			begin
				pwm_out <= 1'b0;
				count <= 0;
			end
		if(pulse_pwm)
			begin
				if(~rst)
					begin
						if (count < temp_reg)
							begin
								pwm_out <= 1'b1;
								count <= count + 1'b1;
							end
						else
							begin
								pwm_out <= 1'b0;
								count <= count + 1'b1;
							end
					end
			end
	end

always @ (posedge clk)
	begin
		if(pulse_pwm)
			begin
				temp_reg <= pwm_duty;	
			end
	end

endmodule
