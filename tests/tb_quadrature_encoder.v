`timescale 1ns / 1ps
// Self-checking testbench for quadrature_encoder: x4 decoding.
// Forward (A leads B) N cycles must add 4N counts; reverse must subtract 4N.
module tb_quadrature_encoder;
  reg clk = 0, rst = 1, A = 0, B = 0;
  wire up, down, pulse, direction;
  wire [31:0] count;
  integer errors = 0, c;
  quadrature_encoder uut (.clk(clk), .rst(rst), .A(A), .B(B), .up(up), .down(down),
                          .pulse(pulse), .direction(direction), .pulse_count(count));
  always #5 clk = ~clk;
  task step(input a, input b); begin A = a; B = b; repeat (8) @(posedge clk); end endtask
  task fwd; begin step(1,0); step(1,1); step(0,1); step(0,0); end endtask
  task rev; begin step(0,1); step(1,1); step(1,0); step(0,0); end endtask
  initial begin
    repeat (4) @(posedge clk); rst = 0; repeat (4) @(posedge clk);
    for (c = 0; c < 10; c = c + 1) fwd;
    if (count !== 32'd40) begin $display("FAIL forward count=%0d (want 40)", count); errors = errors + 1; end
    if (direction !== 1'b1) begin $display("FAIL forward direction=%b", direction); errors = errors + 1; end
    for (c = 0; c < 15; c = c + 1) rev;
    if ($signed(count) !== -20) begin $display("FAIL reverse count=%0d (want -20)", $signed(count)); errors = errors + 1; end
    if (direction !== 1'b0) begin $display("FAIL reverse direction=%b", direction); errors = errors + 1; end
    if (errors == 0) $display("PASS tb_quadrature_encoder");
    $finish;
  end
endmodule
