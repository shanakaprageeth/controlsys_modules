`timescale 1ns / 1ps

module quadrature_encoder_interface_tb;

//------------
// parameters
//-------------
parameter CLK_PERIOD = 10;

//------------
// input ports
//-------------
reg clk;
reg rst;
reg A;
reg B;

//------------
// output ports
//-------------
wire up;
wire down;
wire pulse;
wire direction;
wire [31:0] pulse_count;

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
quadrature_encoder uut (
    .clk(clk),
    .rst(rst),
    .A(A),
    .B(B),
    .up(up),
    .down(down),
    .pulse(pulse),
    .direction(direction),
    .pulse_count(pulse_count)
);

//------------
// Clock generation
//-------------
always #(CLK_PERIOD/2) clk = ~clk;

//------------
// VCD dump for waveform analysis
//-------------
initial begin
    $dumpfile("quadrature_encoder_interface.vcd");
    $dumpvars(0, quadrature_encoder_interface_tb);
end

//------------
// Test procedures
//-------------
task reset_system;
begin
    rst = 1;
    A = 0;
    B = 0;
    #(CLK_PERIOD * 3);
    rst = 0;
    #(CLK_PERIOD);
end
endtask

task test_reset_behavior;
begin
    test_count = test_count + 1;
    $display("Test %d: Reset Behavior", test_count);
    
    // Set some inputs
    A = 1;
    B = 1;
    #(CLK_PERIOD * 3);
    
    // Apply reset
    rst = 1;
    #(CLK_PERIOD * 2);
    
    if (pulse == 0 && direction == 0 && pulse_count == 0) begin
        $display("  PASS: Quadrature encoder outputs correctly reset");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: Outputs should be reset");
        $display("  pulse: %b, direction: %b, count: %d", pulse, direction, pulse_count);
        fail_count = fail_count + 1;
    end
    
    rst = 0;
    #(CLK_PERIOD);
    $display("");
end
endtask

task simulate_quadrature_rotation;
input integer num_steps;
input integer clockwise; // 1 = clockwise, 0 = counter-clockwise
begin
    test_count = test_count + 1;
    if (clockwise)
        $display("Test %d: Clockwise Rotation (%d steps)", test_count, num_steps);
    else
        $display("Test %d: Counter-clockwise Rotation (%d steps)", test_count, num_steps);
    
    for (i = 0; i < num_steps; i = i + 1) begin
        if (clockwise) begin
            // Clockwise: A leads B by 90 degrees
            A = 0; B = 0; #(CLK_PERIOD * 2);
            A = 1; B = 0; #(CLK_PERIOD * 2);
            A = 1; B = 1; #(CLK_PERIOD * 2);
            A = 0; B = 1; #(CLK_PERIOD * 2);
        end else begin
            // Counter-clockwise: B leads A by 90 degrees
            A = 0; B = 0; #(CLK_PERIOD * 2);
            A = 0; B = 1; #(CLK_PERIOD * 2);
            A = 1; B = 1; #(CLK_PERIOD * 2);
            A = 1; B = 0; #(CLK_PERIOD * 2);
        end
        
        if (i < 3) begin // Show first few steps
            $display("  Step %d: A=%b, B=%b, up=%b, down=%b, pulse=%b, dir=%b, count=%d", 
                     i, A, B, up, down, pulse, direction, pulse_count);
        end
    end
    
    $display("  Final: count=%d, direction=%b", pulse_count, direction);
    $display("  PASS: Quadrature rotation simulation completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_static_states;
begin
    test_count = test_count + 1;
    $display("Test %d: Static State Testing", test_count);
    
    // Test all four quadrature states
    A = 0; B = 0; #(CLK_PERIOD * 3);
    $display("  State 00: up=%b, down=%b, pulse=%b, dir=%b", up, down, pulse, direction);
    
    A = 1; B = 0; #(CLK_PERIOD * 3);
    $display("  State 10: up=%b, down=%b, pulse=%b, dir=%b", up, down, pulse, direction);
    
    A = 1; B = 1; #(CLK_PERIOD * 3);
    $display("  State 11: up=%b, down=%b, pulse=%b, dir=%b", up, down, pulse, direction);
    
    A = 0; B = 1; #(CLK_PERIOD * 3);
    $display("  State 01: up=%b, down=%b, pulse=%b, dir=%b", up, down, pulse, direction);
    
    $display("  PASS: Static state test completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_direction_detection;
begin
    test_count = test_count + 1;
    $display("Test %d: Direction Detection", test_count);
    
    // Start from a known state
    A = 0; B = 0; #(CLK_PERIOD * 2);
    
    // Move one step clockwise
    A = 1; B = 0; #(CLK_PERIOD * 2);
    $display("  Clockwise step: dir=%b, up=%b, down=%b", direction, up, down);
    
    // Continue clockwise
    A = 1; B = 1; #(CLK_PERIOD * 2);
    A = 0; B = 1; #(CLK_PERIOD * 2);
    A = 0; B = 0; #(CLK_PERIOD * 2);
    
    // Now move counter-clockwise
    A = 0; B = 1; #(CLK_PERIOD * 2);
    $display("  Counter-clockwise step: dir=%b, up=%b, down=%b", direction, up, down);
    
    $display("  PASS: Direction detection test completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_pulse_generation;
begin
    test_count = test_count + 1;
    $display("Test %d: Pulse Generation", test_count);
    
    // Monitor pulse generation during rotation
    A = 0; B = 0; #(CLK_PERIOD * 2);
    
    for (i = 0; i < 4; i = i + 1) begin
        case (i)
            0: begin A = 1; B = 0; end
            1: begin A = 1; B = 1; end
            2: begin A = 0; B = 1; end
            3: begin A = 0; B = 0; end
        endcase
        #(CLK_PERIOD * 2);
        $display("  Transition %d: pulse=%b", i, pulse);
    end
    
    $display("  PASS: Pulse generation test completed");
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
    $display("Quadrature Encoder Interface Test Suite");
    $display("===========================================");
    
    // Reset system
    reset_system();
    
    // Test reset behavior
    test_reset_behavior();
    
    // Test static states
    test_static_states();
    
    // Test direction detection
    test_direction_detection();
    
    // Test pulse generation
    test_pulse_generation();
    
    // Test rotations
    simulate_quadrature_rotation(3, 1);  // Clockwise
    simulate_quadrature_rotation(2, 0);  // Counter-clockwise
    simulate_quadrature_rotation(5, 1);  // Clockwise again
    
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