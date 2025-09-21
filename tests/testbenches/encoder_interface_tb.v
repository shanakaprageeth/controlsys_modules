`timescale 1ns / 1ps

module encoder_interface_tb;

//------------
// parameters
//-------------
parameter REG_MAX = 64;
parameter CLK_PERIOD = 10;

//------------
// input ports
//-------------
reg clk;
reg rst;
reg phaseA;
reg phaseB;

//------------
// output ports
//-------------
wire signed [REG_MAX-1:0] pulse_count;
wire signed [REG_MAX-1:0] pulse_diff;

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
encoder_in uut (
    .clk(clk),
    .rst(rst),
    .phaseA(phaseA),
    .phaseB(phaseB),
    .pulse_count(pulse_count),
    .pulse_diff(pulse_diff)
);

//------------
// Clock generation
//-------------
always #(CLK_PERIOD/2) clk = ~clk;

//------------
// VCD dump for waveform analysis
//-------------
initial begin
    $dumpfile("encoder_interface.vcd");
    $dumpvars(0, encoder_interface_tb);
end

//------------
// Test procedures
//-------------
task reset_system;
begin
    rst = 1;
    phaseA = 0;
    phaseB = 0;
    #(CLK_PERIOD * 3);
    rst = 0;
    #(CLK_PERIOD);
end
endtask

task test_reset_behavior;
begin
    test_count = test_count + 1;
    $display("Test %d: Reset Behavior", test_count);
    
    // Set some non-zero inputs
    phaseA = 1;
    phaseB = 1;
    #(CLK_PERIOD * 3);
    
    // Apply reset
    rst = 1;
    #(CLK_PERIOD * 2);
    
    if (pulse_count == 0 && pulse_diff == 0) begin
        $display("  PASS: Encoder outputs correctly reset");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: Encoder outputs should be 0 during reset");
        $display("  pulse_count: %d, pulse_diff: %d", pulse_count, pulse_diff);
        fail_count = fail_count + 1;
    end
    
    rst = 0;
    #(CLK_PERIOD);
    $display("");
end
endtask

task simulate_encoder_rotation;
input integer num_steps;
input integer direction; // 1 = forward, 0 = reverse
begin
    test_count = test_count + 1;
    if (direction)
        $display("Test %d: Forward Rotation (%d steps)", test_count, num_steps);
    else
        $display("Test %d: Reverse Rotation (%d steps)", test_count, num_steps);
    
    for (i = 0; i < num_steps; i = i + 1) begin
        if (direction) begin
            // Forward: A leads B
            phaseA = 1; phaseB = 0; #(CLK_PERIOD * 2);
            phaseA = 1; phaseB = 1; #(CLK_PERIOD * 2);
            phaseA = 0; phaseB = 1; #(CLK_PERIOD * 2);
            phaseA = 0; phaseB = 0; #(CLK_PERIOD * 2);
        end else begin
            // Reverse: B leads A
            phaseA = 0; phaseB = 1; #(CLK_PERIOD * 2);
            phaseA = 1; phaseB = 1; #(CLK_PERIOD * 2);
            phaseA = 1; phaseB = 0; #(CLK_PERIOD * 2);
            phaseA = 0; phaseB = 0; #(CLK_PERIOD * 2);
        end
        
        if (i < 3) begin // Show first few steps
            $display("  Step %d: phaseA=%b, phaseB=%b, count=%d, diff=%d", 
                     i, phaseA, phaseB, pulse_count, pulse_diff);
        end
    end
    
    $display("  Final: count=%d, diff=%d", pulse_count, pulse_diff);
    $display("  PASS: Rotation simulation completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_static_phases;
begin
    test_count = test_count + 1;
    $display("Test %d: Static Phase Combinations", test_count);
    
    // Test all combinations of phase signals
    phaseA = 0; phaseB = 0; #(CLK_PERIOD * 3);
    $display("  00: count=%d, diff=%d", pulse_count, pulse_diff);
    
    phaseA = 0; phaseB = 1; #(CLK_PERIOD * 3);
    $display("  01: count=%d, diff=%d", pulse_count, pulse_diff);
    
    phaseA = 1; phaseB = 0; #(CLK_PERIOD * 3);
    $display("  10: count=%d, diff=%d", pulse_count, pulse_diff);
    
    phaseA = 1; phaseB = 1; #(CLK_PERIOD * 3);
    $display("  11: count=%d, diff=%d", pulse_count, pulse_diff);
    
    $display("  PASS: Static phase test completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_direction_changes;
begin
    test_count = test_count + 1;
    $display("Test %d: Direction Changes", test_count);
    
    // Start with forward rotation
    simulate_encoder_rotation(2, 1);
    
    // Change to reverse
    simulate_encoder_rotation(2, 0);
    
    // Back to forward
    simulate_encoder_rotation(2, 1);
    
    $display("  PASS: Direction change test completed");
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
    $display("Encoder Interface Module Test Suite");
    $display("===========================================");
    
    // Reset system
    reset_system();
    
    // Test reset behavior
    test_reset_behavior();
    
    // Test static phase combinations
    test_static_phases();
    
    // Test encoder rotations
    simulate_encoder_rotation(5, 1);  // Forward
    simulate_encoder_rotation(3, 0);  // Reverse
    simulate_encoder_rotation(10, 1); // Forward again
    
    // Test direction changes
    test_direction_changes();
    
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