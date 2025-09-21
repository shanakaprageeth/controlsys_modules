`timescale 1ns / 1ps

module bldc_commutation_tb;
//------------
// parameters
//-------------
parameter REG_SIZE = 16;
parameter CLK_PERIOD = 10; // 100MHz clock

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

//------------
// Test variables
//-------------
integer test_count = 0;
integer pass_count = 0;
integer fail_count = 0;

//------------
// DUT instantiation
//-------------
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

//------------
// Clock generation
//-------------
always #(CLK_PERIOD/2) clk = ~clk;

//------------
// VCD dump for waveform analysis
//-------------
initial begin
    $dumpfile("bldc_commutation.vcd");
    $dumpvars(0, bldc_commutation_tb);
end

//------------
// Test procedures
//-------------
task reset_system;
begin
    rst = 1;
    enable = 0;
    hall_1 = 0;
    hall_2 = 0;
    hall_3 = 0;
    current_in = 0;
    #(CLK_PERIOD * 2);
    rst = 0;
    #(CLK_PERIOD);
    enable = 1;
    #(CLK_PERIOD);
end
endtask

task test_hall_state;
input [2:0] hall_state;
input [REG_SIZE-1:0] test_current;
begin
    test_count = test_count + 1;
    $display("Test %d: Hall State %b", test_count, hall_state);
    
    {hall_1, hall_2, hall_3} = hall_state;
    current_in = test_current;
    
    #(CLK_PERIOD * 2);
    
    $display("  Hall State: %b%b%b", hall_1, hall_2, hall_3);
    $display("  Current In: %d", current_in);
    $display("  Current U:  %d", current_out_U);
    $display("  Current V:  %d", current_out_V);
    $display("  Hall Error: %b", hall_error);
    
    // Test invalid hall states (000 and 111 should trigger error)
    if ((hall_state == 3'b000 || hall_state == 3'b111)) begin
        if (hall_error == 1'b1) begin
            $display("  PASS: Hall error correctly detected");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Hall error should be detected");
            fail_count = fail_count + 1;
        end
    end else begin
        if (hall_error == 1'b0) begin
            $display("  PASS: Valid hall state, no error");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Valid hall state should not trigger error");
            fail_count = fail_count + 1;
        end
    end
    
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
    $display("BLDC Commutation Module Test Suite");
    $display("===========================================");
    
    // Reset system
    reset_system();
    
    // Test all possible hall states with different current values
    test_hall_state(3'b000, 16'd1000);
    test_hall_state(3'b001, 16'd1000);
    test_hall_state(3'b010, 16'd1000);
    test_hall_state(3'b011, 16'd1000);
    test_hall_state(3'b100, 16'd1000);
    test_hall_state(3'b101, 16'd1000);
    test_hall_state(3'b110, 16'd1000);
    test_hall_state(3'b111, 16'd1000);
    
    // Test with different current magnitudes
    test_hall_state(3'b001, 16'd500);
    test_hall_state(3'b010, 16'd2000);
    test_hall_state(3'b011, 16'd0);
    
    // Test enable/disable functionality
    $display("Test %d: Enable/Disable Functionality", test_count + 1);
    test_count = test_count + 1;
    enable = 0;
    {hall_1, hall_2, hall_3} = 3'b001;
    current_in = 16'd1000;
    #(CLK_PERIOD * 2);
    
    if (current_out_U == 0 && current_out_V == 0) begin
        $display("  PASS: Outputs disabled when enable = 0");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: Outputs should be 0 when disabled");
        fail_count = fail_count + 1;
    end
    
    enable = 1;
    #(CLK_PERIOD * 2);
    
    // Test reset functionality
    $display("Test %d: Reset Functionality", test_count + 1);
    test_count = test_count + 1;
    rst = 1;
    #(CLK_PERIOD * 2);
    
    if (current_out_U == 0 && current_out_V == 0) begin
        $display("  PASS: Outputs reset correctly");
        pass_count = pass_count + 1;
    end else begin
        $display("  FAIL: Outputs should be 0 during reset");
        fail_count = fail_count + 1;
    end
    
    rst = 0;
    #(CLK_PERIOD * 2);
    
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