// ---------------------------------------------------------------------
// Velocity Mux Testbench
// ---------------------------------------------------------------------
// Description : Testbench for velocity_mux module
//               Tests all combinations of sel_base and sel_player
//               with each Vx input set high one at a time
// ---------------------------------------------------------------------

`timescale 1ns/1ns

module velocity_mux_tb;

// Signals
reg v0, v1, v2, v3, v4, v5, v6;
reg [1:0] sel_base;
reg [1:0] sel_player;
wire out;

// Test tracking
integer test_num;
integer errors;
integer v_idx, base, player, expected_v_idx;
reg expected;

// Expected output mapping
// sel_base=00: v0, v1, v2, v3 (player 0,1,2,3)
// sel_base=01: v1, v2, v3, v4 (player 0,1,2,3)
// sel_base=10: v2, v3, v4, v5 (player 0,1,2,3)
// sel_base=11: v3, v4, v5, v6 (player 0,1,2,3)

// Instantiate DUT
velocity_mux dut (
    .v0         (v0),
    .v1         (v1),
    .v2         (v2),
    .v3         (v3),
    .v4         (v4),
    .v5         (v5),
    .v6         (v6),
    .sel_base   (sel_base),
    .sel_player (sel_player),
    .out        (out)
);

// Task to set all Vx inputs to 0
task clear_all_v;
begin
    v0 = 0;
    v1 = 0;
    v2 = 0;
    v3 = 0;
    v4 = 0;
    v5 = 0;
    v6 = 0;
end
endtask

// Task to set one Vx input high
task set_v_high;
input [2:0] v_index;
begin
    clear_all_v;
    case (v_index)
        3'd0: v0 = 1;
        3'd1: v1 = 1;
        3'd2: v2 = 1;
        3'd3: v3 = 1;
        3'd4: v4 = 1;
        3'd5: v5 = 1;
        3'd6: v6 = 1;
    endcase
end
endtask

// Function to get expected output
function integer get_expected_v;
input [1:0] base;
input [1:0] player;
begin
    case (base)
        2'b00: get_expected_v = player;           // v0, v1, v2, v3
        2'b01: get_expected_v = player + 1;       // v1, v2, v3, v4
        2'b10: get_expected_v = player + 2;       // v2, v3, v4, v5
        2'b11: get_expected_v = player + 3;       // v3, v4, v5, v6
    endcase
end
endfunction

// Task to check output
task check_output;
input [1:0] base;
input [1:0] player;
input [2:0] v_high;
input expected_out;
begin
    #1; // Small delay for combinational logic
    if (out !== expected_out) begin
        $display("✗ FAIL Test #%0d: sel_base=%0d, sel_player=%0d, v%0d=1 | Expected out=%b, Got out=%b",
                 test_num, base, player, v_high, expected_out, out);
        errors = errors + 1;
    end else begin
        $display("✓ PASS Test #%0d: sel_base=%0d, sel_player=%0d, v%0d=1 | out=%b",
                 test_num, base, player, v_high, out);
    end
    test_num = test_num + 1;
end
endtask

// Main test
initial begin
    $display("==============================================================");
    $display("Testbench: velocity_mux");
    $display("==============================================================");
    $display("Testing all combinations of sel_base, sel_player, and Vx inputs");
    $display("==============================================================\n");
    
    // Initialize
    test_num = 1;
    errors = 0;
    clear_all_v;
    sel_base = 0;
    sel_player = 0;
    
    // Test each Vx input (v0 through v6)
    for (v_idx = 0; v_idx <= 6; v_idx = v_idx + 1) begin
        $display("\n--- Testing with v%0d = 1 (all others = 0) ---", v_idx);
        set_v_high(v_idx);
        
        // Test all combinations of sel_base and sel_player
        for (base = 0; base <= 3; base = base + 1) begin
            for (player = 0; player <= 3; player = player + 1) begin
                sel_base = base[1:0];
                sel_player = player[1:0];
                
                // Determine expected output
                // Expected Vx index based on lookup table
                expected_v_idx = get_expected_v(base[1:0], player[1:0]);
                expected = (v_idx == expected_v_idx) ? 1'b1 : 1'b0;
                
                check_output(base[1:0], player[1:0], v_idx[2:0], expected);
            end
        end
    end
    
    // Test with all Vx = 0
    $display("\n--- Testing with all Vx = 0 ---");
    clear_all_v;
    for (base = 0; base <= 3; base = base + 1) begin
        for (player = 0; player <= 3; player = player + 1) begin
            sel_base = base[1:0];
            sel_player = player[1:0];
            check_output(base[1:0], player[1:0], 3'd7, 1'b0); // v_high=7 means none
        end
    end
    
    // Test with all Vx = 1
    $display("\n--- Testing with all Vx = 1 ---");
    v0 = 1; v1 = 1; v2 = 1; v3 = 1; v4 = 1; v5 = 1; v6 = 1;
    for (base = 0; base <= 3; base = base + 1) begin
        for (player = 0; player <= 3; player = player + 1) begin
            sel_base = base[1:0];
            sel_player = player[1:0];
            check_output(base[1:0], player[1:0], 3'd7, 1'b1); // All high, expect 1
        end
    end
    
    // Summary
    $display("\n==============================================================");
    $display("Test Summary");
    $display("==============================================================");
    $display("Total tests run: %0d", test_num - 1);
    $display("Errors: %0d", errors);
    if (errors == 0) begin
        $display("✓✓✓ ALL TESTS PASSED ✓✓✓");
    end else begin
        $display("✗✗✗ SOME TESTS FAILED ✗✗✗");
    end
    $display("==============================================================\n");
    
    $stop;
end

// Waveform dump
initial begin
    $dumpfile("velocity_mux_tb.vcd");
    $dumpvars(0, velocity_mux_tb);
end

endmodule
