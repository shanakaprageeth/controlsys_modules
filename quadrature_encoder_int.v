
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:43:00 02/14/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:    Quadrature Encoder interface
// Project Name: Active Suspention System
// Target Devices: ALTERA Cyclone 5 / XILINX Spartan 6
// Tool versions: 
// Description: 
//	This module calculate the pulse position of motor with the use of encoders.
// Dependencies: 
//	hardware-- Encoder (not tested as I can remember)
// Revision: 
// Revision 1.0 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module quadrature_encoder(
clk,
rst,
A,
B,
up,
down,
pulse,
direction,
pulse_count
    );

//------------
// parameters
//-------------

//------------
// input ports
//-------------
input 										clk;
input 										rst;
input 										A;
input										B;
//------------
// output ports
//-------------
output 	wire 	up;
output 	wire	down;
output	reg		pulse = 0;
output	reg 	direction = 0;
output reg [31:0] pulse_count = 0;
//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
//up down counter
reg q_0 = 0;
reg q_1 = 0;
reg Q_0 = 0;
reg Q_1 = 0;
// pulse direction
reg [1:0] A_dir = 0;
reg [1:0] B_dir = 0;


//--------
// wires
//-------
wire A_posedge = (A_dir == 2'b01);
wire A_negedge = (A_dir == 2'b10);
wire B_posedge = (B_dir == 2'b01);
wire B_negedge = (B_dir == 2'b10);

// up down counter
always @ (A,B, q_0 , q_1) 	begin
	Q_0 <= A^B;
	Q_1 <= B;
end

always @ (posedge clk)	begin
	if (rst) begin
		q_0 <= 0;
		q_1 <= 0;
	end
	else begin
		q_0 <= Q_0;
		q_1 <= Q_1;
	end
end

assign up = ( ~A & B & ~q_1 ) | (~A & ~q_1 & q_0 )|( A & q_1 & q_0 )|( A & ~B & q_1 );
assign down = ( ~A &  ~B & q_1 ) | (~A & q_1 & ~q_0 )|( A & ~q_1 & ~q_0 )|( A & B & ~q_1 );

// pulse direction

always @ (posedge clk)	begin
	if (rst) begin
		A_dir <= 0;
		B_dir <= 0;
		pulse <= 0;
		direction <= 0;
		pulse_count <= 0;
	end
	else begin
		A_dir <= { A_dir[0], A};
		B_dir <= { B_dir[0], B};
		
		if ( A_posedge) begin
			pulse <= 1'b1;
			if ( ~B_dir[1] )	begin
				direction <= 1'b1;
				pulse_count <= pulse_count + 1'b1;
			end
			else	begin
				direction <= 1'b0;
				pulse_count <= pulse_count - 1'b1;		
			end
		end
		else if ( A_negedge) begin
			pulse <= 1'b1;
			if ( B_dir[1] )	begin
				direction <= 1'b1;
				pulse_count <= pulse_count + 1'b1;
			end
			else	begin
				direction <= 1'b0;
				pulse_count <= pulse_count - 1'b1;		
			end
		end
		else if ( B_posedge) begin
			pulse <= 1'b1;
			if ( A_dir[1] )	begin
				direction <= 1'b1;
				pulse_count <= pulse_count + 1'b1;
			end
			else	begin
				direction <= 1'b0;
				pulse_count <= pulse_count - 1'b1;		
			end
		end
		else if ( B_negedge) begin
			pulse <= 1'b1;
			if ( ~A_dir[1] )	begin
				direction <= 1'b1;
				pulse_count <= pulse_count + 1'b1;
			end
			else	begin
				direction <= 1'b0;
				pulse_count <= pulse_count - 1'b1;		
			end
		end
		else 
		pulse <= 0;
	end
end

	
endmodule
