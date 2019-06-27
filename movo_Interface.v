
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	W.A. Shanaka Prageeth Abeysiriwardhana
// 
// Create Date:    18:43:00 02/14/2014 
// Design Name: 	Active suspension Controller for ALTERA SOC DE1
// Module Name:    SERVOLAND Motor communication module
// Project Name: Active Suspention System
// Target Devices: ALTERA Cyclone 5 / XILINX Spartan 6
// Tool versions: 
// Description: 
//	this is a 16 bit MOVO v2 communication module for motor drivers.
// Dependencies: 
//	hardware-- SERVOLAND SVF series motor drivers
// Revision: 
// Revision 1.0 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module movo_interface(
   clk,
	enable,
	rst,
	value_A,
	value_B,
	clk_movo,
	clk_movo_not,
	data_A,
	data_A_not,
	data_B,
	data_B_not,
	latch,
	latch_not,
	status,
	data_status
	);
//------------
// parameters
//-------------
//------------
// input ports
//-------------
input								clk;
input								enable;
input								rst;
input	signed 	[15:0] 				value_A;
input	signed	[15:0] 				value_B;
//------------
// output ports
//-------------
output 	reg						clk_movo;
output 	wire					clk_movo_not;
output 	reg						data_A;
output 	wire					data_A_not;
output 	reg						data_B;
output 	wire					data_B_not;
output	reg						latch;
output	wire					latch_not;
output	wire					status;
output	wire					data_status;
//---------------------
// bidirectional ports
//--------------------

//----------
// registers
//-----------
reg		signed [15:0]		count = 16'b0;
reg 		[14:0]  				shift_reg_A = 0;
reg 		[14:0]  				shift_reg_B = 0;
//--------
// wires
//-------
assign 	data_A_not = ~data_A;				
assign	data_B_not = ~data_B;				
assign	latch_not = ~latch;				
assign	clk_movo_not = ~clk_movo;
assign 	status = clk_movo;
assign 	data_status = data_A;

always @ (posedge clk)
	begin
		if(rst)
			begin
				count <= 5'b0;
				shift_reg_A <= 0;
				shift_reg_B <= 0;
				data_A <= 0;				
				data_B <= 0;				
				latch <= 0;				
				clk_movo <= 0;				
			end
		if(enable)
			begin
				count <= count + 1'b1;
				if(count == 31)
					begin
						count <= 0;
						shift_reg_A <= value_A[14:0];
						data_A   <= value_A[15];
						shift_reg_B <= value_B[14:0];
						data_B   <= value_B[15];
						clk_movo <= 1;
						latch <= 0;
					end
				else if(count[0] == 1)
					begin
						clk_movo <= 1;			
						shift_reg_A <= { shift_reg_A[13:0], 1'b0};
						data_A  <= shift_reg_A[14];
						shift_reg_B <= { shift_reg_B[13:0], 1'b0};
						data_B  <= shift_reg_B[14];							
					end
				else if (count[0] == 0)
					begin
						clk_movo <= 0;
						if (count == 30)
							latch <= 1;
					end						
			end
	end
	
endmodule
