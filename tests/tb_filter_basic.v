`timescale 1ns / 1ps
// Characterisation test for filter_basic (filter_basic_fixed.v).
// With the default GAIN_1 = 1, GAIN_2 = 16 the update is
//   y <- (y_prev + x + 16*y) >> 4  =  y + (x + y_prev)/16,
// which is an accumulator, not a low-pass filter. A constant input therefore
// makes the output grow without bound. This test records that known defect:
// it PASSES while the module behaves as analysed and FAILS if the behaviour
// changes, so a future fix must update this test and docs/KNOWN_ISSUES.md.
module tb_filter_basic;
  reg clk = 0, rst = 1;
  reg [31:0] x = 0;
  wire [31:0] y;
  integer errors = 0;
  filter_basic uut (.clk(clk), .rst(rst), .filter_input(x), .filter_output(y));
  always #5 clk = ~clk;
  initial begin
    repeat (3) @(posedge clk); rst = 0;
    x = 32'd160;
    repeat (400) @(posedge clk); #1;
    // a unity-gain low-pass would settle near 160; the accumulator passes 1000
    if (y <= 32'd1000) begin
      $display("FAIL filter_basic y=%0d: behaviour changed, update KNOWN_ISSUES.md", y);
      errors = errors + 1;
    end
    if (errors == 0) $display("PASS tb_filter_basic (known defect reproduced: y=%0d after 400 clk)", y);
    $finish;
  end
endmodule
