`timescale 1ns / 1ps

module bldc_commutation_tb;
//------------
// parameters
//-------------
parameter REG_SIZE = 16;

//------------
// input ports
//-------------
reg clk;
reg rst;
reg enable;

reg hall_1;
reg hall_2;
reg hall_3;

reg [REG_SIZE-1:0] current_in;
//------------
// output ports
//-------------
wire [REG_SIZE-1:0] current_out_U;
wire [REG_SIZE-1:0] current_out_V;
wire hall_error;


BLDC_commutation uut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .hall_1(hall_1),
    .hall_2(hall_2),
    .hall_3(hall_3),
    .current_in(current_in),
    .current_out_U(current_out_U),
    .current_out_V(current_out_V),
    .hall_error(hall_error)
);

initial begin
    clk = 0;
    rst = 1;
    enable = 1;
    hall_1=1'b0; hall_2=1'b0; hall_3=1'b0;
    current_in = 16'b000000000001000;
    #10 rst = 0;

    // Test case 1: Check initial commutation output
    #20 hall_1=1'b1; hall_2=1'b1; hall_3=1'b1;
    #25 if (hall_error !== 1'b1) $display("Test case 1 failed");

    // Add more test cases as needed

    #30 $finish;
end

always #5 clk = ~clk;

endmodule