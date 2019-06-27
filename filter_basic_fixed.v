`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: W A Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:13:44 01/11/2014 
// Design Name: 
// Module Name:    fixed point filter first order
// Project Name: 	Active suspension
// Target Devices: 
// Tool versions: 
// Description: 
//	  basic fixed point filter
// Dependencies: 
//    will not work well 
// Revision:  1.0
// Revision 0.01 - File Created
// Additional Comments: simulated file reference dob_test.v
//
//////////////////////////////////////////////////////////////////////////////////
module filter_basic( clk, rst, filter_input, filter_output );

//------------
// parameters
//-------------
parameter REG_MAX = 32;
parameter GAIN_1 = 1;
parameter GAIN_2 = 16;
//------------
// input ports
//-------------
input clk;
input rst;
input [REG_MAX - 1 :0] filter_input;
//------------
// output ports
//-------------
output reg [REG_MAX - 1: 0] filter_output = 0;
//----------
// registers
//-----------
reg signed [REG_MAX - 1 : 0 ] filter_out_prev = 0;
reg signed [REG_MAX + 3 : 0 ] filter_out_temp = 0; //se;ecte temp size according to filter constants

always @(posedge clk) begin
	if (rst) begin
		filter_out_prev <= 0;
		filter_output <= 0;
		filter_out_temp <= 0;
	end
	else begin
		filter_out_temp <= filter_out_prev +( GAIN_1 * filter_input )+ (GAIN_2 * filter_output);
		filter_output <= filter_out_temp[REG_MAX + 3 : 4 ];
		filter_out_prev <= filter_output;
	end
end


endmodule
