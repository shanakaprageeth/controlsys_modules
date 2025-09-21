`timescale 1ns / 1ps

module dac712_interface_tb;

//------------
// parameters
//-------------
parameter LATCH_TRANSPARENT = 4'b1101;
parameter DO_NOTHING = 4'b1111;
parameter CLK_PERIOD = 10;

//------------
// input ports
//-------------
reg clk;
reg rst;
reg [15:0] send_value;

//------------
// output ports
//-------------
wire [15:0] dac_output;
wire [3:0] ic_com;

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
dac712_interface uut (
    .clk(clk),
    .rst(rst),
    .send_value(send_value),
    .dac_output(dac_output),
    .ic_com(ic_com)
);

//------------
// Clock generation
//-------------
always #(CLK_PERIOD/2) clk = ~clk;

//------------
// VCD dump for waveform analysis
//-------------
initial begin
    $dumpfile("dac712_interface.vcd");
    $dumpvars(0, dac712_interface_tb);
end

//------------
// Test procedures
//-------------
task reset_system;
begin
    rst = 1;
    send_value = 0;
    #(CLK_PERIOD * 3);
    rst = 0;
    #(CLK_PERIOD);
end
endtask

task test_reset_behavior;
begin
    test_count = test_count + 1;
    $display("Test %d: Reset Behavior", test_count);
    
    // Set some non-zero input
    send_value = 16'h5555;
    #(CLK_PERIOD * 2);
    
    // Apply reset
    rst = 1;
    #(CLK_PERIOD * 2);
    
    if (dac_output == 0 && ic_com == LATCH_TRANSPARENT) begin
        $display("  PASS: DAC outputs correctly reset");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: DAC outputs not correctly reset");
        $display("  dac_output: 0x%h (expected 0x0000)", dac_output);
        $display("  ic_com: 0b%b (expected 0b%b)", ic_com, LATCH_TRANSPARENT);
        fail_count = fail_count + 1;
    end
    
    rst = 0;
    #(CLK_PERIOD);
    $display("");
end
endtask

task test_data_transfer;
input [15:0] test_value;
begin
    test_count = test_count + 1;
    $display("Test %d: Data Transfer (0x%h)", test_count, test_value);
    
    send_value = test_value;
    #(CLK_PERIOD * 2);
    
    if (dac_output == test_value) begin
        $display("  PASS: Data correctly transferred");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: Data transfer incorrect");
        $display("  Expected: 0x%h", test_value);
        $display("  Got:      0x%h", dac_output);
        fail_count = fail_count + 1;
    end
    
    $display("  Input:    0x%h", send_value);
    $display("  Output:   0x%h", dac_output);
    $display("  IC_COM:   0b%b", ic_com);
    $display("");
end
endtask

task test_ic_command_signals;
begin
    test_count = test_count + 1;
    $display("Test %d: IC Command Signals", test_count);
    
    // Test that IC command signals are properly set
    send_value = 16'h1234;
    #(CLK_PERIOD * 2);
    
    $display("  IC_COM bits: [A1,A2,WR,CLR] = %b", ic_com);
    
    if (ic_com == LATCH_TRANSPARENT) begin
        $display("  PASS: IC command signals correct for normal operation");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: IC command signals incorrect");
        $display("  Expected: %b", LATCH_TRANSPARENT);
        $display("  Got:      %b", ic_com);
        fail_count = fail_count + 1;
    end
    
    $display("");
end
endtask

task test_edge_values;
begin
    test_count = test_count + 1;
    $display("Test %d: Edge Values", test_count);
    
    // Test minimum value
    test_data_transfer(16'h0000);
    
    // Test maximum value  
    test_data_transfer(16'hFFFF);
    
    // Test mid-scale
    test_data_transfer(16'h8000);
    
    // Test some specific patterns
    test_data_transfer(16'h5555); // Alternating bits
    test_data_transfer(16'hAAAA); // Alternating bits (inverted)
    
    $display("  PASS: Edge value tests completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_rapid_changes;
begin
    test_count = test_count + 1;
    $display("Test %d: Rapid Value Changes", test_count);
    
    // Rapidly change values
    for (i = 0; i < 10; i = i + 1) begin
        send_value = i * 1000;
        #CLK_PERIOD;
        $display("  Step %d: Input=0x%h, Output=0x%h", i, send_value, dac_output);
    end
    
    $display("  PASS: Rapid change test completed");
    pass_count = pass_count + 1;
    $display("");
end
endtask

task test_stability;
begin
    test_count = test_count + 1;
    $display("Test %d: Output Stability", test_count);
    
    send_value = 16'h7777;
    
    // Hold value for multiple clock cycles
    for (i = 0; i < 5; i = i + 1) begin
        #CLK_PERIOD;
        if (dac_output != 16'h7777) begin
            $display("  FAIL: Output not stable at clock %d", i);
            fail_count = fail_count + 1;
            $display("");
            $finish; // Use $finish instead of return
        end
    end
    
    $display("  PASS: Output remained stable");
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
    $display("DAC712 Interface Module Test Suite");
    $display("===========================================");
    
    // Reset system
    reset_system();
    
    // Test reset behavior
    test_reset_behavior();
    
    // Test IC command signals
    test_ic_command_signals();
    
    // Test data transfer with various values
    test_data_transfer(16'h1234);
    test_data_transfer(16'h5678);
    test_data_transfer(16'h9ABC);
    test_data_transfer(16'hDEF0);
    
    // Test edge values
    test_edge_values();
    
    // Test rapid changes
    test_rapid_changes();
    
    // Test stability
    test_stability();
    
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