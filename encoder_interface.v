`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:43:00 02/14/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:   Encoder interface
// Project Name: Active Suspention System
// Target Devices: ALTERA Cyclone 5 / XILINX Spartan 6
// Tool versions: 
// Description: 
//	This module calculate the pulse position of motor with the use of encoders.
// Dependencies: 
//	hardware-- Encoder (tested with Renishaw LM10)
// Revision: 
// Revision 1.0 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module encoder_in(
	clk,
	rst, 
	phaseA, 
	phaseB, 
	pulse_count,
	pulse_diff
    );
//------------
// parameters
//-------------
parameter REG_MAX = 64;

//------------
// input ports
//-------------
input 						clk;
input 						rst;
input 						phaseA;
input 						phaseB;
//------------
// output ports
//-------------
output 	reg signed[REG_MAX-1:0] 	pulse_count = 0;
output 	reg signed[REG_MAX-1:0] 	pulse_diff = 0;
//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
reg 	[15:0]			count = 0;
reg 	[2:0] 			phaseA_del = 0;
reg 	[2:0] 			phaseB_del = 0;
reg 	signed [REG_MAX-1:0] 	pulse_count_prev = 0;

//--------
// wires
//-------


// position calculation
always @(posedge clk) 
	begin
		phaseA_del <= {phaseA_del[1:0],phaseA};
		phaseB_del <= {phaseB_del[1:0],phaseB};
		if ( rst ) 
			begin
				phaseA_del <= 0;
				phaseB_del <= 0;
				pulse_count <= 0;
				pulse_count_prev <= 0;
				pulse_diff <= 0;
				count <= 0;
			end	
		if (~rst) 
			begin
				count <= count + 1'b1;
				if(enable) 
					begin						
						if(direction) 
							begin
								if(count == 10000)
									begin
										pulse_diff <= pulse_count - pulse_count_prev;
										pulse_count <= pulse_count + 1'b1;
										pulse_count_prev <= pulse_count;	
										count <= 0;
									end
								else
									pulse_count <= pulse_count + 1'b1;
							end
						if (~direction) 
							begin
								if(count == 10000)
									begin
										pulse_diff <= pulse_count - pulse_count_prev;										
										pulse_count <= pulse_count - 1'b1;
										pulse_count_prev <= pulse_count;	
										count <= 0;
									end
								else
									pulse_count <= pulse_count - 1'b1;
							end
					end
				if(~enable)
					begin
						if(count == 10000)
							begin
								pulse_diff <= pulse_count - pulse_count_prev;
								pulse_count_prev <= pulse_count;	
								count <= 0;
							end
					end				
			end		
	end
	
// direction and synchronous time calculator
wire enable = phaseA_del[1] ^ phaseA_del[2] ^ phaseB_del[1] ^ phaseB_del[2];
wire direction = phaseA_del[1] ^ phaseB_del[2];

	
endmodule
