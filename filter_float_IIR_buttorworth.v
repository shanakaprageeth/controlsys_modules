`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: W A Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:13:44 01/11/2014 
// Design Name: 
// Module Name:    Float_Filter IIR buttorworth second order filter
// Project Name: 	Active suspension
// Target Devices: 
// Tool versions: 
// Description: 
//	a module that act as a first order filter for float values
// Dependencies: 
//  DSP floating point module
//	sample time :1MHz
// 	Filter Constant: 1kHz
//	
// Revision:  1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module filter_butterworth( clk, rst, filter_input, filter_output );

//------------
// parameters
//-------------
reg [31:0] ZERO = 32'b00000000000000000000000000000000; // filter constants add 32 bit IEEE742 number here
reg [31:0] X_K = 32'b00111011011011010100111001001101; // filter constants add 32 bit IEEE742 number here
reg [31:0] X_1_K = 32'b00111011111011010101011010110000; // filter constants add 32 bit IEEE742 number here
reg [31:0] X_2_K = 32'b00111011011011010100111001001101; // filter constants add 32 bit IEEE742 number here
reg [31:0] Y_1_K = 32'b00111111111010010101100000010000; // filter constants add 32 bit IEEE742 number here
reg [31:0] Y_2_K = 32'b00111111010101100100110000110000; // filter constants add 32 bit IEEE742 number here

//------------
// input ports
//-------------
input clk;
input rst;
input [31 :0] filter_input;
//------------
// output ports
//-------------
output  [31: 0] filter_output;
//----------
// registers
//----------
reg [31: 0] y_2 = 0;
reg [31: 0] y_1 = 0;
reg [31: 0] x_2 = 0;
reg [31: 0] x_1 = 0;

wire [31: 0] K_y_2_temp_1;
wire [31: 0] K_y_2_temp_2;
wire [31: 0] K_y_2;
wire [31: 0] K_y_1;
wire [31: 0] K_x_2;
wire [31: 0] K_x_1;
wire [31: 0] K_x;
wire [31: 0] x_x_1;
wire [31: 0] x_2_y_1;
wire [31: 0] x_y_sum;

reg [15: 0] counter = 0;

always @(posedge clk) begin
	if (rst) begin
		y_2 <= 0;
		y_1 <= 0;
		x_2 <= 0;
		x_1 <= 0;
		counter <= 0;
	end
	else begin			
		counter <= counter + 1'b1;
		if (counter == 10000) begin
			y_2 <= y_1;
			y_1 <= filter_output;
			x_2 <= x_1;
			x_1 <= filter_input;
			counter <= 0;
		end		
	end
end

// * FIlter const
float_multi	float_multi_K_x (
	.clock ( clk ),
	.dataa ( filter_input ),
	.datab ( X_K ),
	.result ( K_x)
	);	
float_multi	float_multi_K_x_1 (
	.clock ( clk ),
	.dataa ( x_1 ),
	.datab ( X_1_K ),
	.result ( K_x_1)
	);
float_multi	float_multi_K_x_2 (
	.clock ( clk ),
	.dataa ( x_2 ),
	.datab ( X_2_K ),
	.result ( K_x_2)
	);
float_multi	float_multi_K_y_1 (
	.clock ( clk ),
	.dataa ( y_1 ),
	.datab ( Y_1_K),
	.result ( K_y_1)
	);	
float_multi	float_multi_K_y_2 (
	.clock ( clk ),
	.dataa ( y_2 ),
	.datab ( Y_2_K),
	.result ( K_y_2)
	);
	
float_add_sub	float_add_sub_x_x_1(
	.clock ( clk ),
	.dataa ( K_x ),
	.datab ( K_x_1 ),
	.add_sub ( 1'b1 ),
	.result ( x_x_1)
	);	
float_add_sub	float_add_sub_x_2_y_1(
	.clock ( clk ),
	.dataa ( K_x_2 ),
	.datab ( K_y_1 ),
	.add_sub ( 1'b1 ),
	.result ( x_2_y_1)
	);
float_add_sub	float_add_sub_y_2_temp_1(
	.clock ( clk ),
	.dataa ( K_y_2 ),
	.datab ( ZERO ),
	.add_sub ( 1'b1 ),
	.result ( K_y_2_temp_1)
	);
float_add_sub	float_add_sub_y_2_temp_2(
	.clock ( clk ),
	.dataa ( K_y_2_temp_1 ),
	.datab ( ZERO ),
	.add_sub ( 1'b1 ),
	.result ( K_y_2_temp_2)
	);
float_add_sub	float_add_sub_x_y_sum(
	.clock ( clk ),
	.dataa ( x_x_1 ),
	.datab ( x_2_y_1 ),
	.add_sub ( 1'b1 ),
	.result ( x_y_sum)
	);	
// x- y calculation
float_add_sub	float_add_sub_out(
	.clock ( clk ),
	.dataa ( x_y_sum ),
	.datab ( K_y_2_temp_2 ),
	.add_sub ( 1'b0 ),
	.result ( filter_output)
	);
	
	
endmodule
