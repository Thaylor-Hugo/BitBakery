// Module that generates and moves the map for the delivery game
// Map is 128 rows x 4 lanes, moves 8x faster than before to maintain same visual speed

module generate_map (
    input clock,
    input reset,
    input move_map,
    input sel_obstacle,     // 1 for obstacle, 0 for no obstacle
    input sel_objective,    // 1 for objective, 0 for no objective
    output [511:0] map_obstacles_flat,
    output [511:0] map_objectives_flat,
    output reg obstacle_generated,  // Pulses when obstacle is inserted
    output reg objective_generated  // Pulses when objective is inserted
);

reg [3:0] map_obstacles [0:127];
reg [3:0] map_objectives [0:127];

wire [3:0] s_random_obstacles_address, s_random_objectives_address;
wire [3:0] s_random_obstacle, s_random_objective;
wire [3:0] s_selected_obstacle, s_selected_objective;
integer i;

initial begin
    // Initialize map obstacles and objectives
    for (i = 0; i < 128; i = i + 1) begin
        map_obstacles[i] <= 4'b0000;
        map_objectives[i] <= 4'b0000;
    end
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 128; i = i + 1) begin
            map_obstacles[i] <= 4'b0000;
            map_objectives[i] <= 4'b0000;
        end
        obstacle_generated <= 1'b0;
        objective_generated <= 1'b0;
    end else if (move_map) begin
        // Shift map down
        for (i = 0; i < 127; i = i + 1) begin
            map_obstacles[i] <= map_obstacles[i+1];
            map_objectives[i] <= map_objectives[i+1];
        end
        // Insert new obstacles and objectives at the top
        map_obstacles[127] <= s_selected_obstacle;
        map_objectives[127] <= s_selected_objective;
        
        // Generate feedback signals
        obstacle_generated <= sel_obstacle && (s_selected_obstacle != 4'b0000);
        objective_generated <= sel_objective && (s_selected_objective != 4'b0000);
    end else begin
        // Clear feedback signals when not moving
        obstacle_generated <= 1'b0;
        objective_generated <= 1'b0;
    end
end

random_4 random_obstacles (
    .clock          (clock),
    .reset          (reset),
    .write_enable   (1'b1),
    .address        (s_random_obstacles_address)
);

random_4 random_objectives (
    .clock          (clock),
    .reset          (reset),
    .write_enable   (1'b1),
    .address        (s_random_objectives_address)
);

delivery_rom rom_obstacles (
    .clock (clock),
    .address (s_random_obstacles_address),
    .data_out (s_random_obstacle)
);

delivery_rom rom_objectives (
    .clock (clock),
    .address (s_random_objectives_address),
    .data_out (s_random_objective)
);

mux2x1 #(.N(4)) mux_obstacles (
    .D0 (4'b0000),
    .D1 (s_random_obstacle[3:0]),
    .SEL (sel_obstacle),
    .OUT (s_selected_obstacle)
);

mux2x1 #(.N(4)) mux_objectives (
    .D0 (4'b0000),
    .D1 (s_random_objective[3:0]),
    .SEL (sel_objective),
    .OUT (s_selected_objective)
);

// Generate flat outputs for all 128 rows
genvar j;
generate
    for (j = 0; j < 128; j = j + 1) begin : flatten_map
        assign map_obstacles_flat[j*4 +: 4] = map_obstacles[j];
        assign map_objectives_flat[j*4 +: 4] = map_objectives[j];
    end
endgenerate

endmodule