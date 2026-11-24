`timescale 1ns / 1ps
// Self-checking testbench for pwm_out: over any 2^N consecutive PWM ticks the
// output must be high for exactly `duty` ticks.
module tb_pwm_out;
  localparam N = 8;
  reg clk = 0, rst = 1, pulse = 1;
  reg [N-1:0] duty = 0;
  wire out;
  integer i, highs, errors = 0, k;
  integer duties [0:4];
  pwm_out #(.PWM_RESOLUTION(N)) uut (.clk(clk), .pulse_pwm(pulse), .rst(rst),
                                     .pwm_duty(duty), .pwm_out(out));
  always #5 clk = ~clk;
  initial begin
    duties[0] = 0; duties[1] = 1; duties[2] = 64; duties[3] = 128; duties[4] = 255;
    for (k = 0; k < 5; k = k + 1) begin
      rst = 1; duty = duties[k];
      repeat (3) @(posedge clk);
      rst = 0;
      repeat (2 * (1 << N)) @(posedge clk);       // settle one full period
      highs = 0;
      for (i = 0; i < (1 << N); i = i + 1) begin
        @(posedge clk); #1;
        if (out) highs = highs + 1;
      end
      if (highs !== duties[k]) begin
        $display("FAIL pwm duty=%0d highs=%0d", duties[k], highs);
        errors = errors + 1;
      end
    end
    if (errors == 0) $display("PASS tb_pwm_out");
    $finish;
  end
endmodule
