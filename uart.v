`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    10:37:11 01/20/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:    UART 
// Project Name: Active Suspention System
// Target Devices: 
// Tool versions: 
// Description: 
//     This is a uart communication module. Not tested.
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart(
clk,
pulse_uart,
enable,
rst,
tx_data,
rx,
rx_data,
tx
    );
//------------
// parameters
//-------------

//------------
// input ports
//-------------
input 						clk;
input 						pulse_uart;
input 						rst;
input 						enable;
input 	[7:0]				tx_data;
input 						rx;
//------------
// output ports
//-------------
output 	reg [7:0]	 	rx_data = 0;
output 	reg				tx = 0;
//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
reg 	[4:0] 	count_tx = 0;
reg 	[4:0] 	count_rx = 0;
reg 	[7:0] 	shift_reg_tx = 0;
reg 	[7:0]  	shift_reg_rx = 0;
//--------
// wires
//-------



always @(posedge clk )
	begin
		if (rst)
			begin
				count_tx <= 0;
				count_rx <= 0;
				shift_reg_tx <= 0;
				shift_reg_rx <= 0;
			end
		if(pulse_uart)
			begin
				if (~rst)
					begin
						if(enable)
							if (count_tx == 9)
								count_tx <= 0;
						if(~rx)
							if (count_rx == 9)
								begin
									count_tx <= 0;
								end
						if (count_tx == 0)
							begin
								shift_reg_tx <= tx_data[7:1];
								tx    <= tx_data[0];
								count_tx <= count_tx + 1'b1;
							end
						if (count_tx != 0)
							begin
								if (count_tx != 9)
									shift_reg_tx <= {1'b0, shift_reg_tx[6:1]};
									tx  <= shift_reg_tx[0];
									count_tx <= count_tx + 1'b1;
							end
						if (count_rx == 0)
							begin
								shift_reg_rx <= { rx , shift_reg_rx[7:1]};
								count_rx <= count_rx + 1'b1;
							end
						if (count_rx != 0)
							begin
								if (count_tx != 8)
									begin
										shift_reg_rx <= { rx , shift_reg_rx[7:1]};
										count_rx <= count_rx + 1'b1;
									end
								if (count_tx == 8)
									begin
										rx_data <= { rx , shift_reg_rx[7:1]};
										count_rx <= count_rx + 1'b1;
									end		
							end				
					end
				end
	end
endmodule
