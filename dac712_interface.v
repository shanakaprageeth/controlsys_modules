`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:43:00 02/14/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:    DAC712 interface. 
// Project Name: Active Suspention System
// Target Devices: ALTERA Cyclone 5 / XILINX Spartan 6
// Tool versions: 
// Description: 
//	   This module can operate with DAC712 IC for Digital to Analog Conversion.
// Dependencies: 
//     hardware DAC712 IC
// Revision:  1.0
// Revision 0.01 - File Created
// Additional Comments: simulated file reference dac712_interface_test.v
//
//////////////////////////////////////////////////////////////////////////////////
module dac712_interface (clk, rst, send_value, dac_output , ic_com);

//------------
// parameters
//-------------
parameter LATCH_TRANSPARENT = 4'b1101;
parameter DO_NOTHING = 4'b1111;
//------------
// input ports
//-------------
input clk;
input rst;
input [15:0] send_value;
//------------
// output ports
//-------------
output reg [15:0] dac_output = 0;
output reg [3:0] ic_com = LATCH_TRANSPARENT; //ic_com [A1,A2,WR,CLR]
//----------
// registers
//-----------


always @(posedge clk) begin
	if (rst) begin
		dac_output <= 0;
		ic_com <= LATCH_TRANSPARENT;
	end
	else begin
		dac_output <= send_value;
	end
end

 
endmodule

