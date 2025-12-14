// ---------------------------------------------------------------------
// Generate Map Testbench
// ---------------------------------------------------------------------
// Description : Testbench for generate_map module
//               Tests map generation and movement with obstacles/objectives
// ---------------------------------------------------------------------

`timescale 1us/1us

module generate_map_tb;

// Signals
reg clock;
reg reset;
reg move_map;
reg sel_obstacle;
reg sel_objective;
wire [63:0] map_obstacles_flat;
wire [63:0] map_objectives_flat;
wire obstacle_generated;
wire objective_generated;

// Unflattened maps for better visualization
wire [3:0] map_obstacles [0:15];
wire [3:0] map_objectives [0:15];

// Timing control
integer time_counter;
integer move_counter;
integer sel_counter;
integer k;

// Clock period (1kHz = 1ms = 1000us)
parameter CLOCK_PERIOD = 1000;

// Instantiate DUT
generate_map dut (
    .clock                  (clock),
    .reset                  (reset),
    .move_map               (move_map),
    .sel_obstacle           (sel_obstacle),
    .sel_objective          (sel_objective),
    .map_obstacles_flat     (map_obstacles_flat),
    .map_objectives_flat    (map_objectives_flat),
    .obstacle_generated     (obstacle_generated),
    .objective_generated    (objective_generated)
);

// Unflatten maps for easier viewing
assign map_obstacles[0] = map_obstacles_flat[3:0];
assign map_obstacles[1] = map_obstacles_flat[7:4];
assign map_obstacles[2] = map_obstacles_flat[11:8];
assign map_obstacles[3] = map_obstacles_flat[15:12];
assign map_obstacles[4] = map_obstacles_flat[19:16];
assign map_obstacles[5] = map_obstacles_flat[23:20];
assign map_obstacles[6] = map_obstacles_flat[27:24];
assign map_obstacles[7] = map_obstacles_flat[31:28];
assign map_obstacles[8] = map_obstacles_flat[35:32];
assign map_obstacles[9] = map_obstacles_flat[39:36];
assign map_obstacles[10] = map_obstacles_flat[43:40];
assign map_obstacles[11] = map_obstacles_flat[47:44];
assign map_obstacles[12] = map_obstacles_flat[51:48];
assign map_obstacles[13] = map_obstacles_flat[55:52];
assign map_obstacles[14] = map_obstacles_flat[59:56];
assign map_obstacles[15] = map_obstacles_flat[63:60];

assign map_objectives[0] = map_objectives_flat[3:0];
assign map_objectives[1] = map_objectives_flat[7:4];
assign map_objectives[2] = map_objectives_flat[11:8];
assign map_objectives[3] = map_objectives_flat[15:12];
assign map_objectives[4] = map_objectives_flat[19:16];
assign map_objectives[5] = map_objectives_flat[23:20];
assign map_objectives[6] = map_objectives_flat[27:24];
assign map_objectives[7] = map_objectives_flat[31:28];
assign map_objectives[8] = map_objectives_flat[35:32];
assign map_objectives[9] = map_objectives_flat[39:36];
assign map_objectives[10] = map_objectives_flat[43:40];
assign map_objectives[11] = map_objectives_flat[47:44];
assign map_objectives[12] = map_objectives_flat[51:48];
assign map_objectives[13] = map_objectives_flat[55:52];
assign map_objectives[14] = map_objectives_flat[59:56];
assign map_objectives[15] = map_objectives_flat[63:60];

// Clock generator (1kHz)
always #(CLOCK_PERIOD/2) clock = ~clock;

// Task to display map state
task display_maps;
    integer j;
    begin
        $display("\n[%0.1f ms] ========== MAP STATE ==========", $time/1000.0);
        $display("sel_obstacle=%b, sel_objective=%b", sel_obstacle, sel_objective);
        $display("OBSTACLES                     OBJECTIVES");
        for (j = 15; j >= 0; j = j - 1) begin
            $display("Row %2d: %b (0x%h)        Row %2d: %b (0x%h)", 
                     j, map_obstacles[j], map_obstacles[j],
                     j, map_objectives[j], map_objectives[j]);
        end
        $display("=====================================\n");
    end
endtask

// Monitor move_map pulses
always @(posedge move_map) begin
    if (!reset) begin
        move_counter = move_counter + 1;
        $display("[%0.1f ms] >>> MOVE_MAP pulse #%0d <<<", $time/1000.0, move_counter);
    end
end

// Monitor obstacle generation
always @(posedge obstacle_generated) begin
    if (!reset) begin
        $display("[%0.1f ms] *** OBSTACLE GENERATED! ***", $time/1000.0);
    end
end

// Monitor objective generation
always @(posedge objective_generated) begin
    if (!reset) begin
        $display("[%0.1f ms] *** OBJECTIVE GENERATED! ***", $time/1000.0);
    end
end

// Main test process
initial begin
    $display("==============================================================");
    $display("Testbench: generate_map");
    $display("==============================================================");
    $display("Clock: 1kHz (1ms period)");
    $display("move_map: pulse every 500ms");
    $display("sel toggle: every 2000ms (alternate obstacles/objectives)");
    $display("Duration: 30 seconds");
    $display("==============================================================\n");
    
    // Initialize signals
    clock = 0;
    reset = 1;
    move_map = 0;
    sel_obstacle = 0;
    sel_objective = 0;
    time_counter = 0;
    move_counter = 0;
    sel_counter = 0;
    
    // Reset period
    #(10*CLOCK_PERIOD);
    reset = 0;
    $display("[%0.1f ms] Reset released, starting test...\n", $time/1000.0);
    #(10*CLOCK_PERIOD);
    
    // Display initial state
    display_maps();
    
    // Main test loop - run for 30 seconds (30,000ms = 30,000,000us)
    while (time_counter < 30000) begin
        
        // Every 500ms (500,000us): pulse move_map
        if (time_counter > 0 && (time_counter % 500 == 0)) begin
            // Determine if we should generate an item on this move
            // Every 2000ms (4 moves): generate an item
            if (time_counter % 2000 == 0) begin
                sel_counter = sel_counter + 1;
                
                if (sel_counter % 2 == 1) begin
                    // Odd: request obstacle generation
                    $display("[%0.1f ms] >>> Requesting OBSTACLE generation", $time/1000.0);
                    sel_obstacle = 1;
                    sel_objective = 0;
                end else begin
                    // Even: request objective generation
                    $display("[%0.1f ms] >>> Requesting OBJECTIVE generation", $time/1000.0);
                    sel_obstacle = 0;
                    sel_objective = 1;
                end
            end else begin
                // No generation request on this move
                sel_obstacle = 0;
                sel_objective = 0;
            end
            
            // Pulse move_map with sel signals stable
            move_map = 1;
            #CLOCK_PERIOD;
            move_map = 0;
            
            // Wait one more clock for generation feedback
            #CLOCK_PERIOD;
            
            // Clear sel signals after generation confirmed
            sel_obstacle = 0;
            sel_objective = 0;
            
            // Display map after movement (every 2s)
            if ((time_counter % 2000 == 0)) begin
                display_maps();
            end
        end
        
        // Progress indicator every 5 seconds
        if (time_counter > 0 && (time_counter % 5000 == 0)) begin
            $display("[%0.1f ms] === %0d seconds elapsed ===", $time/1000.0, time_counter/1000);
        end
        
        #CLOCK_PERIOD;
        time_counter = time_counter + 1;
    end
    
    // Final map display
    $display("\n[%0.1f ms] Test duration complete. Final map state:", $time/1000.0);
    display_maps();
    
    // Summary
    $display("==============================================================");
    $display("Test Summary");
    $display("==============================================================");
    $display("Total simulation time: %0.1f seconds", $time/1000000.0);
    $display("Total move_map pulses: %0d", move_counter);
    $display("Total mode toggles: %0d", sel_counter);
    $display("Expected move_map pulses: 60 (every 0.5s for 30s)");
    $display("Expected mode toggles: 15 (every 2s for 30s)");
    $display("==============================================================\n");
    
    $stop;
end

// Waveform dump
initial begin    
    $dumpfile("generate_map_tb.vcd");
    $dumpvars(0, generate_map_tb);
    // Dump individual map elements for better viewing
    for (k = 0; k < 16; k = k + 1) begin
        $dumpvars(0, dut.map_obstacles[k]);
        $dumpvars(0, dut.map_objectives[k]);
    end
end

endmodule
