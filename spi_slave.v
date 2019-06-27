`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:43:00 02/14/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:    SPI slave
// Project Name: Active Suspention System
// Target Devices: ALTERA Cyclone 5 / XILINX Spartan 6
// Tool versions: 
// Description: 
//    SPI slave communication module that could be interfaced with sensors
//    used for communication with ARM mbed controller
// Dependencies: 
//	cpol = 0
//	cpha = 0
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_slave(
	clk,
	rst,
	enable,
	sclk,
	cs,
	mosi,
	data_tx,
	
	miso,
	data_rx
    );
//------------
// parameters
//-------------
parameter CPOL = 1;
parameter CPHA = 1;
parameter SPI_BITS = 16;
//------------
// input ports
//-------------
input							clk;
input							enable;
input							rst;
input	[SPI_BITS-1:0] 			data_tx;
input							sclk;
input							cs;	
input							mosi;	
//------------
// output ports
//-------------
output 			reg						miso = 0;
output	 		reg 	[SPI_BITS-1:0] 		data_rx = 0;


//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
reg 		[2:0]								state = 0;
reg			signed [7:0]						count = 8'b0;
reg	 			[SPI_BITS-1:0] 					data_rx_temp = 0;
reg	 			[SPI_BITS-1:0] 					data_tx_temp = 0;
//--------
// wires
//-------

// spi signal generator module
//-----------logic-----------------

always @(posedge clk )	begin
	if (rst)	begin
		state <= 0;
		count <= 8'b0;				
	end
	else begin
		if	(enable)	begin
			if(cs == 1)		begin	
				data_tx_temp <= data_tx;
				state <= 0;
				count <= 0;
			end
			else begin
				case (state)
					0	:begin	
						//initial spi start
						if(~CPHA) miso <= data_tx_temp[SPI_BITS-1];
						if (sclk == ~CPOL)begin
							if (CPHA) begin
								miso <= data_tx_temp[SPI_BITS-1];
								count <= count + 1'b1;
							end
							if (~CPHA) begin
								data_rx_temp[SPI_BITS-1] <= mosi;
							end
							state <= 1;
						end
					end
					1	: begin
						if(sclk == ~CPOL)begin
							if (CPHA) begin
								data_rx_temp[SPI_BITS-count] <= mosi;
								if (SPI_BITS == count) begin
									data_rx <= data_tx_temp;
									count <= 1'b1;
								end
							end
							if (~CPHA) begin								
								count <= count + 1'b1;
								miso <= data_tx_temp[SPI_BITS-count];
								if (SPI_BITS == count) begin
									data_rx <= data_tx_temp;
									count <= 1'b1;
								end
							end	
							state <= 2;						
						end
					end
					2	:begin
						if(sclk == CPOL)begin					
							if (CPHA) begin
								count <= count + 1'b1;
								miso <= data_tx_temp[SPI_BITS-count];
							end
							if (~CPHA) begin
								data_rx_temp[SPI_BITS-count] <= mosi;
							end
							state <= 1;	
						end
					end
				endcase
			end
		end
	end
end

endmodule