// ---------------------------------------------------------------------
// Contador Max Testbench
// ---------------------------------------------------------------------
// Description : Testbench for contador_max module
//               Tests counting behavior and stop at maximum value
// ---------------------------------------------------------------------

`timescale 1ns/1ns

module contador_max_tb;

// Test parameters
parameter M = 8;
parameter N = 4;

// Signals
reg clock;
reg zera_as;
reg zera_s;
reg conta;
wire [N-1:0] Q;
wire fim;
wire meio;

// Clock period
parameter CLOCK_PERIOD = 20; // 50 MHz

// Instantiate DUT (Device Under Test)
contador_max #(
    .M(M),
    .N(N)
) dut (
    .clock   (clock),
    .zera_as (zera_as),
    .zera_s  (zera_s),
    .conta   (conta),
    .Q       (Q),
    .fim     (fim),
    .meio    (meio)
);

// Clock generator
always #(CLOCK_PERIOD/2) clock = ~clock;

// Monitor changes
always @(posedge clock) begin
    if (conta && !zera_as && !zera_s) begin
        $display("[%0t ns] Q=%0d | fim=%b | meio=%b", $time, Q, fim, meio);
    end
end

// Test stimulus
initial begin
    $display("==============================================================");
    $display("Testbench: contador_max");
    $display("==============================================================");
    $display("Parameters: M=%0d, N=%0d", M, N);
    $display("Expected behavior: Count 0 to %0d and STOP", M-1);
    $display("==============================================================\n");
    
    // Initialize signals
    clock = 0;
    zera_as = 0;
    zera_s = 0;
    conta = 0;
    
    // Test 1: Asynchronous reset
    $display("TEST 1: Asynchronous Reset (zera_as)");
    $display("--------------------------------------------------------------");
    zera_as = 1;
    #(2*CLOCK_PERIOD);
    zera_as = 0;
    #(CLOCK_PERIOD);
    $display("After async reset: Q=%0d (expected 0)\n", Q);
    
    // Test 2: Count to maximum
    $display("TEST 2: Count to Maximum");
    $display("--------------------------------------------------------------");
    conta = 1;
    #(CLOCK_PERIOD);
    
    // Count through all values
    repeat (M + 5) begin  // Extra cycles to verify it stops
        #(CLOCK_PERIOD);
    end
    
    if (Q == M-1 && fim == 1) begin
        $display("✓ PASS: Counter stopped at max value Q=%0d, fim=%b", Q, fim);
    end else begin
        $display("✗ FAIL: Counter did not stop correctly. Q=%0d, fim=%b", Q, fim);
    end
    $display("");
    
    // Test 3: Verify counter stays at max
    $display("TEST 3: Verify Counter Stays at Max");
    $display("--------------------------------------------------------------");
    $display("Applying 10 more clock cycles with conta=1...");
    repeat (10) begin
        #(CLOCK_PERIOD);
        if (Q != M-1) begin
            $display("✗ FAIL: Counter changed from max! Q=%0d", Q);
        end
    end
    if (Q == M-1) begin
        $display("✓ PASS: Counter remained at max value Q=%0d\n", Q);
    end
    
    // Test 4: Synchronous reset
    $display("TEST 4: Synchronous Reset (zera_s)");
    $display("--------------------------------------------------------------");
    zera_s = 1;
    #(CLOCK_PERIOD);
    zera_s = 0;
    #(CLOCK_PERIOD);
    $display("After sync reset: Q=%0d (expected 0)", Q);
    
    if (Q == 0 && fim == 0) begin
        $display("✓ PASS: Synchronous reset successful\n");
    end else begin
        $display("✗ FAIL: Synchronous reset failed. Q=%0d, fim=%b\n", Q, fim);
    end
    
    // Test 5: Count again after reset
    $display("TEST 5: Count Again After Reset");
    $display("--------------------------------------------------------------");
    conta = 1;
    #(CLOCK_PERIOD);
    
    repeat (M + 2) begin
        #(CLOCK_PERIOD);
    end
    
    if (Q == M-1 && fim == 1) begin
        $display("✓ PASS: Counter reached max again Q=%0d\n", Q);
    end else begin
        $display("✗ FAIL: Counter did not reach max. Q=%0d\n", Q);
    end
    
    // Test 6: Disable counting
    $display("TEST 6: Disable Counting (conta=0)");
    $display("--------------------------------------------------------------");
    zera_s = 1;
    #(CLOCK_PERIOD);
    zera_s = 0;
    conta = 0;
    #(CLOCK_PERIOD);
    
    $display("Initial Q=%0d with conta=0", Q);
    repeat (10) begin
        #(CLOCK_PERIOD);
    end
    
    if (Q == 0) begin
        $display("✓ PASS: Counter did not increment with conta=0\n");
    end else begin
        $display("✗ FAIL: Counter incremented with conta=0. Q=%0d\n", Q);
    end
    
    // Test 7: Check meio (middle) signal
    $display("TEST 7: Check Meio (Middle) Signal");
    $display("--------------------------------------------------------------");
    zera_s = 1;
    #(CLOCK_PERIOD);
    zera_s = 0;
    conta = 1;
    #(CLOCK_PERIOD);
    
    repeat (M) begin
        if (Q == M/2-1 && meio == 1) begin
            $display("✓ PASS: meio signal asserted at Q=%0d (M/2-1=%0d)", Q, M/2-1);
        end
        #(CLOCK_PERIOD);
    end
    $display("");
    
    // Summary
    $display("==============================================================");
    $display("Test Complete");
    $display("==============================================================");
    $display("Final state: Q=%0d, fim=%b, meio=%b", Q, fim, meio);
    $display("==============================================================\n");
    
    $stop;
end

// Waveform dump
initial begin
    $dumpfile("contador_max_tb.vcd");
    $dumpvars(0, contador_max_tb);
end

endmodule
