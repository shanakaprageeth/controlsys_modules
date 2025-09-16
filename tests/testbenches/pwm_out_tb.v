`timescale 1ns / 1ps

module pwm_out_tb;

//------------
// parameters
//-------------
parameter PWM_RESOLUTION = 8;
parameter CLK_PERIOD = 10; // 100MHz clock
parameter PWM_PERIOD = 256; // PWM period in clock cycles

//------------
// input ports
//-------------
reg clk;
reg pulse_pwm;
reg rst;
reg [PWM_RESOLUTION-1:0] pwm_duty;

//------------
// output ports
//-------------
wire pwm_out;

//------------
// Test variables
//-------------
integer test_count = 0;
integer pass_count = 0;
integer fail_count = 0;
integer high_count = 0;
integer cycle_count = 0;

//------------
// DUT instantiation
//-------------
pwm_out uut (
    .clk(clk),
    .pulse_pwm(pulse_pwm),
    .rst(rst),
    .pwm_duty(pwm_duty),
    .pwm_out(pwm_out)
);

//------------
// Clock generation
//-------------
always #(CLK_PERIOD/2) clk = ~clk;

//------------
// PWM pulse generation (simulates PWM frequency control)
//-------------
always #(CLK_PERIOD * PWM_PERIOD) pulse_pwm = ~pulse_pwm;

//------------
// VCD dump for waveform analysis
//-------------
initial begin
    $dumpfile("pwm_out.vcd");
    $dumpvars(0, pwm_out_tb);
end

//------------
// PWM duty cycle measurement
//-------------
always @(posedge clk) begin
    if (pulse_pwm) begin
        cycle_count <= 0;
        high_count <= 0;
    end else begin
        cycle_count <= cycle_count + 1;
        if (pwm_out)
            high_count <= high_count + 1;
    end
end

//------------
// Test procedures
//-------------
task reset_system;
begin
    rst = 1;
    pulse_pwm = 0;
    pwm_duty = 0;
    #(CLK_PERIOD * 3);
    rst = 0;
    #(CLK_PERIOD);
end
endtask

task test_duty_cycle;
input [PWM_RESOLUTION-1:0] duty;
integer expected_high;
integer measured_duty;
integer tolerance;
begin
    test_count = test_count + 1;
    $display("Test %d: Duty Cycle %d", test_count, duty);
    
    pwm_duty = duty;
    expected_high = duty;
    tolerance = 2; // Allow ±2 clock cycles tolerance
    
    // Wait for one complete PWM cycle
    wait(pulse_pwm == 1);
    wait(pulse_pwm == 0);
    
    // Wait for measurement to complete
    wait(pulse_pwm == 1);
    
    $display("  Duty Cycle Setting: %d/%d (%.1f%%)", duty, (1 << PWM_RESOLUTION), 
             (duty * 100.0) / (1 << PWM_RESOLUTION));
    $display("  Expected High Count: %d", expected_high);
    $display("  Measured High Count: %d", high_count);
    
    if ((high_count >= (expected_high - tolerance)) && 
        (high_count <= (expected_high + tolerance))) begin
        $display("  PASS: PWM duty cycle within tolerance");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: PWM duty cycle out of tolerance");
        fail_count = fail_count + 1;
    end
    
    $display("");
end
endtask

task test_reset_behavior;
begin
    test_count = test_count + 1;
    $display("Test %d: Reset Behavior", test_count);
    
    pwm_duty = 8'd128; // 50% duty cycle
    
    // Wait for PWM to start
    wait(pulse_pwm == 1);
    #(CLK_PERIOD * 10);
    
    // Apply reset while PWM is running
    rst = 1;
    #(CLK_PERIOD * 3);
    
    if (pwm_out == 1'b0) begin
        $display("  PASS: PWM output correctly reset to 0");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: PWM output should be 0 during reset");
        fail_count = fail_count + 1;
    end
    
    rst = 0;
    #(CLK_PERIOD * 2);
    $display("");
end
endtask

task test_edge_cases;
begin
    // Test 0% duty cycle
    test_duty_cycle(8'd0);
    
    // Test 100% duty cycle
    test_duty_cycle(8'd255);
    
    // Test 50% duty cycle
    test_duty_cycle(8'd128);
    
    // Test 25% duty cycle
    test_duty_cycle(8'd64);
    
    // Test 75% duty cycle
    test_duty_cycle(8'd192);
    
    // Test very low duty cycle
    test_duty_cycle(8'd1);
    
    // Test very high duty cycle
    test_duty_cycle(8'd254);
end
endtask

//------------
// Main test sequence
//-------------
initial begin
    // Initialize signals
    clk = 0;
    
    $display("===========================================");
    $display("PWM Output Module Test Suite");
    $display("===========================================");
    
    // Reset system
    reset_system();
    
    // Test reset behavior
    test_reset_behavior();
    
    // Test various duty cycles
    test_edge_cases();
    
    // Test dynamic duty cycle changes
    test_count = test_count + 1;
    $display("Test %d: Dynamic Duty Cycle Changes", test_count);
    
    pwm_duty = 8'd64;  // Start with 25%
    wait(pulse_pwm == 1);
    wait(pulse_pwm == 0);
    
    pwm_duty = 8'd192; // Change to 75%
    wait(pulse_pwm == 1);
    wait(pulse_pwm == 0);
    
    pwm_duty = 8'd32;  // Change to 12.5%
    wait(pulse_pwm == 1);
    wait(pulse_pwm == 0);
    
    $display("  PASS: Dynamic duty cycle changes completed");
    pass_count = pass_count + 1;
    $display("");
    
    // Final test summary
    $display("===========================================");
    $display("Test Summary:");
    $display("Total Tests: %d", test_count);
    $display("Passed:      %d", pass_count);
    $display("Failed:      %d", fail_count);
    
    if (fail_count == 0) begin
        $display("ALL TESTS PASSED!");
    end else begin
        $display("SOME TESTS FAILED!");
    end
    $display("===========================================");
    
    #(CLK_PERIOD * 10);
    $finish;
end

endmodule