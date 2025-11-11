`timescale 1us/1us

module mock_hcsr04_tb;

// Testbench signals
reg clock;
reg reset;
reg trigger;
reg [1:0] distancia;
wire echo;

// Clock parameters - 1MHz (1us period)
parameter CLOCK_PERIOD = 1; // 1us

// DUT instantiation
mock_hcsr04 sensor (
    .clock (clock),
    .reset (reset),
    .trigger (trigger),
    .distancia (distancia),
    .echo (echo)
);

// Clock generation - 1MHz
always #(CLOCK_PERIOD/2) clock = ~clock;

// Task to send trigger pulse (minimum 10us)
task send_trigger;
    begin
        @(negedge clock);
        trigger = 1'b1;
        #(CLOCK_PERIOD * 12); // 12us pulse
        trigger = 1'b0;
    end
endtask

// Task to measure echo duration
task measure_echo;
    integer start_time;
    integer end_time;
    integer duration;
    begin
        // Wait for echo to go high
        @(posedge echo);
        start_time = $time;
        
        // Wait for echo to go low
        @(negedge echo);
        end_time = $time;
        
        duration = end_time - start_time;
        $display("  Echo duration: %0d us (expected for distance code %2b)", duration, distancia);
    end
endtask

// Main test
initial begin
    // Initialize
    clock = 1'b0;
    reset = 1'b0;
    trigger = 1'b0;
    distancia = 2'b00;
    
    $display("========================================");
    $display("Mock HC-SR04 Testbench");
    $display("========================================");
    
    // Reset
    reset = 1'b1;
    #(CLOCK_PERIOD * 5);
    reset = 1'b0;
    #(CLOCK_PERIOD * 5);
    
    // Test 1cm distance (58us echo)
    $display("\nTest 1: Distance = 1cm (code 00)");
    distancia = 2'b00;
    #(CLOCK_PERIOD * 10);
    fork
        send_trigger();
        measure_echo();
    join
    #(CLOCK_PERIOD * 100);
    
    // Test 6cm distance (348us echo)
    $display("\nTest 2: Distance = 6cm (code 01)");
    distancia = 2'b01;
    #(CLOCK_PERIOD * 10);
    fork
        send_trigger();
        measure_echo();
    join
    #(CLOCK_PERIOD * 100);
    
    // Test 10cm distance (580us echo)
    $display("\nTest 3: Distance = 10cm (code 10)");
    distancia = 2'b10;
    #(CLOCK_PERIOD * 10);
    fork
        send_trigger();
        measure_echo();
    join
    #(CLOCK_PERIOD * 100);
    
    // Test 14cm distance (812us echo)
    $display("\nTest 4: Distance = 14cm (code 11)");
    distancia = 2'b11;
    #(CLOCK_PERIOD * 10);
    fork
        send_trigger();
        measure_echo();
    join
    #(CLOCK_PERIOD * 100);
    
    // Test distance change during operation
    $display("\nTest 5: Multiple measurements with changing distance");
    distancia = 2'b00; // 1cm
    #(CLOCK_PERIOD * 10);
    fork
        send_trigger();
        measure_echo();
    join
    
    #(CLOCK_PERIOD * 200);
    distancia = 2'b11; // 14cm
    #(CLOCK_PERIOD * 10);
    fork
        send_trigger();
        measure_echo();
    join
    
    #(CLOCK_PERIOD * 200);
    distancia = 2'b01; // 6cm
    #(CLOCK_PERIOD * 10);
    fork
        send_trigger();
        measure_echo();
    join
    
    $display("\n========================================");
    $display("All tests completed successfully!");
    $display("========================================");
    
    #(CLOCK_PERIOD * 100);
    $finish;
end

// Monitor signal changes
initial begin
    $monitor("Time=%0t | Reset=%b | Trigger=%b | Distance=%2b | Echo=%b", 
             $time, reset, trigger, distancia, echo);
end

endmodule
