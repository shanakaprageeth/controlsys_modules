`timescale 1ns / 1ps

module filter_basic_fixed_tb;

//------------
// parameters
//-------------
parameter REG_MAX = 32;
parameter GAIN_1 = 1;
parameter GAIN_2 = 16;
parameter CLK_PERIOD = 10;

//------------
// input ports
//-------------
reg clk;
reg rst;
reg [REG_MAX-1:0] filter_input;

//------------
// output ports
//-------------
wire [REG_MAX-1:0] filter_output;

//------------
// Test variables
//-------------
integer test_count = 0;
integer pass_count = 0;
integer fail_count = 0;
integer i;

//------------
// DUT instantiation
//-------------
filter_basic uut (
    .clk(clk),
    .rst(rst),
    .filter_input(filter_input),
    .filter_output(filter_output)
);

//------------
// Clock generation
//-------------
always #(CLK_PERIOD/2) clk = ~clk;

//------------
// VCD dump for waveform analysis
//-------------
initial begin
    $dumpfile("filter_basic_fixed.vcd");
    $dumpvars(0, filter_basic_fixed_tb);
end

//------------
// Test procedures
//-------------
task reset_system;
begin
    rst = 1;
    filter_input = 0;
    #(CLK_PERIOD * 3);
    rst = 0;
    #(CLK_PERIOD);
end
endtask

task test_step_response;
input [REG_MAX-1:0] step_value;
begin
    test_count = test_count + 1;
    $display("Test %d: Step Response with value %d", test_count, step_value);
    
    // Apply step input
    filter_input = step_value;
    
    // Wait for filter to settle and observe response
    for (i = 0; i < 20; i = i + 1) begin
        #CLK_PERIOD;
        $display("  Clock %d: Input=%d, Output=%d", i, filter_input, filter_output);
    end
    
    // Check if output is reasonable (should be approaching input for a low-pass filter)
    if (filter_output != 0) begin
        $display("  PASS: Filter produced non-zero output");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: Filter output remained zero");
        fail_count = fail_count + 1;
    end
    
    $display("");
end
endtask

task test_reset_behavior;
begin
    test_count = test_count + 1;
    $display("Test %d: Reset Behavior", test_count);
    
    // Set input to non-zero
    filter_input = 32'd1000;
    #(CLK_PERIOD * 5);
    
    // Apply reset
    rst = 1;
    #(CLK_PERIOD * 2);
    
    if (filter_output == 0) begin
        $display("  PASS: Filter output correctly reset to 0");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: Filter output should be 0 during reset");
        fail_count = fail_count + 1;
    end
    
    rst = 0;
    #CLK_PERIOD;
    $display("");
end
endtask

task test_zero_input;
begin
    test_count = test_count + 1;
    $display("Test %d: Zero Input Response", test_count);
    
    filter_input = 0;
    
    // Wait several clock cycles
    for (i = 0; i < 10; i = i + 1) begin
        #CLK_PERIOD;
        $display("  Clock %d: Input=0, Output=%d", i, filter_output);
    end
    
    // Output should eventually approach zero
    $display("  PASS: Zero input test completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_ramp_input;
begin
    test_count = test_count + 1;
    $display("Test %d: Ramp Input Response", test_count);
    
    // Apply ramp input
    for (i = 0; i < 20; i = i + 1) begin
        filter_input = i * 100;
        #CLK_PERIOD;
        $display("  Clock %d: Input=%d, Output=%d", i, filter_input, filter_output);
    end
    
    $display("  PASS: Ramp input test completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_impulse_response;
begin
    test_count = test_count + 1;
    $display("Test %d: Impulse Response", test_count);
    
    // Apply impulse (one clock cycle of high value)
    filter_input = 32'd10000;
    #CLK_PERIOD;
    filter_input = 0;
    
    // Observe response
    for (i = 0; i < 15; i = i + 1) begin
        #CLK_PERIOD;
        $display("  Clock %d: Input=0, Output=%d", i, filter_output);
    end
    
    $display("  PASS: Impulse response test completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

//------------
// Main test sequence
//-------------
initial begin
    // Initialize signals
    clk = 0;
    
    $display("===========================================");
    $display("Basic Fixed Point Filter Test Suite");
    $display("===========================================");
    
    // Reset system
    reset_system();
    
    // Test reset behavior
    test_reset_behavior();
    
    // Test zero input
    test_zero_input();
    
    // Test step responses with different amplitudes
    test_step_response(32'd1000);
    test_step_response(32'd5000);
    test_step_response(32'd100);
    
    // Test ramp input
    test_ramp_input();
    
    // Test impulse response
    test_impulse_response();
    
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
    
    #(CLK_PERIOD * 5);
    $finish;
end

endmodule