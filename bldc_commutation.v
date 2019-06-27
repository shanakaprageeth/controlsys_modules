
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:43:00 02/14/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:  BLDC motor commutation module
// Project Name: Active Suspention System
// Target Devices: Any FPGA, Servoland motor controller current command, 
// Tool versions: 
// Description: 
//      IMPORTANT: please test and edit hall sensor arrangement your own motor before using.
//	This module is used for Trapizoidal BLDC commutation using current command.
//  This should be interfaced with movo_interface to communicate with motor driver
// Dependencies: 
//	hardware-- 
//       Input : Linear BLDC Motor with hall sensors (tested with S250T Nippon pulse linear motor)
//       Output :(through movo_interface module) TTL to Servoland BLDC Motor Controller 2 Phase current command (SVF series)
// software-- 16 bit current controller module
// Revision: 
// Revision 1.0 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module BLDC_commutation(
	clk,
	rst,
	enable,
	
	hall_1,
	hall_2,
	hall_3,
	
	current_in,
	
	current_out_U,
	current_out_V,
	hall_error
    );
//------------
// parameters
//-------------
parameter REG_SIZE = 16;
//------------
// input ports
//-------------
input clk;
input rst;
input enable;

input hall_1;
input hall_2;
input hall_3;

input [REG_SIZE-1:0] current_in;
//------------
// output ports
//-------------
output reg [REG_SIZE-1:0] current_out_U = 0;
output reg [REG_SIZE-1:0] current_out_V = 0;
output reg hall_error = 0;
//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
reg [4:0] state = 0;
//--------
// wires
//-------
always @(posedge clk)begin
	if(rst) begin
		current_out_U <= 0;
		current_out_V <= 0;
		state <= 0;
	end
	else begin
		if (enable) begin
			case(state)
				0: begin
					if ( (hall_1 & hall_2 & hall_3) || (hall_1 & hall_2 & hall_3) ) begin
						current_out_U <= 0;
						current_out_V <= 0;
						hall_error <= 1;
					end
					if (hall_1 & ~hall_2 & ~hall_3) begin
						current_out_U <= -current_in;
						current_out_V <= current_in;
						hall_error <= 0;
						state <= 1;
					end
					if (hall_1 & hall_2 & ~hall_3) begin
						current_out_U <= 0;
						current_out_V <= current_in;
						hall_error <= 0;
						state <= 2;						
					end
					if (~hall_1 & hall_2 & ~hall_3) begin
						current_out_U <= current_in;
						current_out_V <= 0;						
						hall_error <= 0;
						state <= 3;
					end
					if (~hall_1 & hall_2 & hall_3) begin
						current_out_U <= current_in;
						current_out_V <= -current_in;	
						hall_error <= 0;
						state <= 4;						
					end
					if (~hall_1 & ~hall_2 & hall_3) begin
						current_out_U <= 0;
						current_out_V <= -current_in;
						hall_error <= 0;
						state <= 5;
					end
					if (hall_1 & ~hall_2 & hall_3) begin
						current_out_U <= -current_in;
						current_out_V <= 0;
						hall_error <= 0;
						state <= 6;
					end
				end
				1: begin
					if ( hall_2 == 1 ) begin
						current_out_U <= 0;
						current_out_V <= current_in;
						state <= 2;
					end
					if ( hall_3 == 1 ) begin
						current_out_U <= -current_in;
						current_out_V <= 0;
						state <= 6;
					end
					if ( ~(hall_1 & ~hall_2 & ~hall_3) ) begin
						hall_error <= 1;
						state <= 0;
					end					
				end
				2: begin
					if ( ~hall_1 == 1 ) begin
						current_out_U <= current_in;
						current_out_V <= 0;	
						state <= 3;
					end
					if ( ~hall_2 == 1 ) begin
						current_out_U <= -current_in;
						current_out_V <= current_in;
						state <= 1;
					end
					if ( ~(hall_1 & hall_2 & ~hall_3) ) begin
						hall_error <= 1;
						state <= 0;
					end	
				
				end
				3: begin
					if ( hall_3 == 1 ) begin
						current_out_U <= current_in;
						current_out_V <= -current_in;
						state <= 4;
					end
					if ( hall_1 == 1 ) begin
						current_out_U <= 0;
						current_out_V <= current_in;
						state <= 2;
					end
					if ( ~(~hall_1 & hall_2 & ~hall_3) ) begin
						hall_error <= 1;
						state <= 0;
					end	
				
				end
				4: begin
					if ( ~hall_2 == 1 ) begin
						current_out_U <= 0;
						current_out_V <= -current_in;
						state <= 5;
					end
					if ( ~hall_3 == 1 ) begin
						current_out_U <= current_in;
						current_out_V <= 0;	
						state <= 3;
					end
					if ( ~(~hall_1 & hall_2 & hall_3) ) begin
						hall_error <= 1;
						state <= 0;
					end	
				
				end
				5: begin
					if ( hall_1 == 1 ) begin
						current_out_U <= -current_in;
						current_out_V <= 0;
						state <= 6;
					end
					if ( hall_2 == 1 ) begin
						current_out_U <= current_in;
						current_out_V <= -current_in;
						state <= 4;
					end
					if ( ~(~hall_1 & ~hall_2 & hall_3) ) begin
						hall_error <= 1;
						state <= 0;
					end	
				
				end
				6: begin
					if ( ~hall_3 == 1 ) begin
						current_out_U <= -current_in;
						current_out_V <= current_in;
						state <= 1;
					end
					if ( ~hall_1 == 1 ) begin
						current_out_U <= 0;
						current_out_V <= -current_in;
						state <= 5;
					end
					if ( ~(hall_1 & ~hall_2 & hall_3) ) begin
						hall_error <= 1;
						state <= 0;
					end	
				
				end
				default: begin
					state <= 0;
				end	
			endcase	
		end
		else begin
			current_out_U <= 0;
			current_out_V <= 0;
			state <= 0;
		end
	end

end



endmodule
