// Module that generates and moves the map for the delivery game

module generate_map (
    input clock,
    input reset,
    input move_map,
    input sel_obstacle,     // 1 for obstacle, 0 for no obstacle
    input sel_objective,    // 1 for objective, 0 for no objective
    output [63:0] map_obstacles_flat,
    output [63:0] map_objectives_flat,
    output reg obstacle_generated,  // Pulses when obstacle is inserted
    output reg objective_generated  // Pulses when objective is inserted
);

reg [3:0] map_obstacles [0:15];
reg [3:0] map_objectives [0:15];

wire [3:0] s_random_obstacles_address, s_random_objectives_address;
wire [3:0] s_random_obstacle, s_random_objective;
wire [3:0] s_selected_obstacle, s_selected_objective;
integer i;

initial begin
    // Initialize map obstacles and objectives
    for (i = 0; i < 16; i = i + 1) begin
        map_obstacles[i] <= 4'b0000;
        map_objectives[i] <= 4'b0000;
    end
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 16; i = i + 1) begin
            map_obstacles[i] <= 4'b0000;
            map_objectives[i] <= 4'b0000;
        end
        obstacle_generated <= 1'b0;
        objective_generated <= 1'b0;
    end else if (move_map) begin
        // Shift map down
        for (i = 0; i < 15; i = i + 1) begin
            map_obstacles[i] <= map_obstacles[i+1];
            map_objectives[i] <= map_objectives[i+1];
        end
        // Insert new obstacles and objectives at the top
        map_obstacles[15] <= s_selected_obstacle;
        map_objectives[15] <= s_selected_objective;
        
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

assign map_obstacles_flat[3:0] = map_obstacles[0];
assign map_objectives_flat[3:0] = map_objectives[0];
assign map_obstacles_flat[7:4] = map_obstacles[1];
assign map_objectives_flat[7:4] = map_objectives[1];
assign map_obstacles_flat[11:8] = map_obstacles[2];
assign map_objectives_flat[11:8] = map_objectives[2];
assign map_obstacles_flat[15:12] = map_obstacles[3];
assign map_objectives_flat[15:12] = map_objectives[3];
assign map_obstacles_flat[19:16] = map_obstacles[4];
assign map_objectives_flat[19:16] = map_objectives[4];
assign map_obstacles_flat[23:20] = map_obstacles[5];
assign map_objectives_flat[23:20] = map_objectives[5];
assign map_obstacles_flat[27:24] = map_obstacles[6];
assign map_objectives_flat[27:24] = map_objectives[6];
assign map_obstacles_flat[31:28] = map_obstacles[7];
assign map_objectives_flat[31:28] = map_objectives[7];
assign map_obstacles_flat[35:32] = map_obstacles[8];
assign map_objectives_flat[35:32] = map_objectives[8];
assign map_obstacles_flat[39:36] = map_obstacles[9];
assign map_objectives_flat[39:36] = map_objectives[9];
assign map_obstacles_flat[43:40] = map_obstacles[10];
assign map_objectives_flat[43:40] = map_objectives[10];
assign map_obstacles_flat[47:44] = map_obstacles[11];
assign map_objectives_flat[47:44] = map_objectives[11];
assign map_obstacles_flat[51:48] = map_obstacles[12];
assign map_objectives_flat[51:48] = map_objectives[12];
assign map_obstacles_flat[55:52] = map_obstacles[13];
assign map_objectives_flat[55:52] = map_objectives[13];
assign map_obstacles_flat[59:56] = map_obstacles[14];
assign map_objectives_flat[59:56] = map_objectives[14];
assign map_obstacles_flat[63:60] = map_obstacles[15];
assign map_objectives_flat[63:60] = map_objectives[15];

endmodule