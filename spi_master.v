`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:43:00 02/14/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:    spi master module
// Project Name: Active Suspention System
// Target Devices: ALTERA Cyclone 5 / XILINX Spartan 6
// Tool versions: 
// Description: 
//	  This is a spi master module
// Dependencies: 
//    used with ADXL345 acclerometer
// Revision:  1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_master(
	clk_spi_drive,
	rst,
	enable,
	sclk_spi_drive,
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
input							clk_spi_drive;
input							enable;
input							rst;
input	[SPI_BITS-1:0] 			data_tx;
input							sclk_spi_drive;
	
input							miso;	
//------------
// output ports
//-------------

output reg		sclk_spi_drive;
output reg							cs;
output reg									mosi = 0;
output reg	 			[SPI_BITS-1:0] 		data_rx = 0;


//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
reg 		[2:0]								state = 0;
reg			signed [7:0]						count = 8'b0;
reg			signed [7:0]						wait_count = 8'b0;
reg	 		[SPI_BITS-1:0] 					data_rx_temp = 0;
reg	 		[SPI_BITS-1:0] 					data_tx_temp = 0;
//--------
// wires
//-------

// spi signal generator module
//-----------logic-----------------

always @(posedge clk_spi_drive ) begin
	if (rst)	begin
		state <= 0;
		count <= 8'b0;	
		wait_count <= 255;		
	end
	else begin
		if	(enable)	begin
			if(cs == 1)		begin	
				data_tx_temp <= data_tx;
				state <= 0;
				count <= 0;
				wait_count <= wait_count - 1'b1;
				if (wait_count == 0) begin
					data_tx_temp <= data_tx;					
					if(~CPHA) mosi <= data_tx_temp[SPI_BITS-1];
					cs = 0;	
					state <= 0;					
				end
			end
			else begin
				case (state)
					0	:begin	
						if (CPHA) begin
							mosi <= data_tx_temp[SPI_BITS-1];
							count <= count + 1'b1;
						end
						if (~CPHA) begin
							data_rx_temp[SPI_BITS-1] <= miso;
						end
						state <= 1;					
					end
					1	: begin						
						if (CPHA) begin
							data_rx_temp[SPI_BITS-count] <= miso;
							if (SPI_BITS == count) begin
								data_rx <= data_tx_temp;
								count <= 1'b1;
							end
						end		
						if (~CPHA) begin								
							count <= count + 1'b1;
							mosi <= data_tx_temp[SPI_BITS-count];
							if (SPI_BITS == count) begin
								data_rx <= data_tx_temp;
								count <= 1'b1;
							end
						end	
						state <= 2;						
					end					
					2	: begin
						if(sclk_spi_drive == CPOL) begin					
							if (CPHA) begin
								count <= count + 1'b1;
								mosi <= data_tx_temp[SPI_BITS-count];
							end
							if (~CPHA) begin
								data_rx_temp[SPI_BITS-count] <= miso;
							end
							state <= 1;	
						end
					end
					default : begin
						state <= 0;
					end
				endcase
			end
		end
	end
end

endmodule