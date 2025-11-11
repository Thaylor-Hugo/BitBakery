
module delivery_game_fd (
    input clock,
    input reset,
    input [6:0] botoes,
    input echo,
    input count_map,
    input get_velocity,
    output [2:0] pontuacao,
    output reg game_over,
    output pwm,
    output trigger,
    output velocity_ready,
    output [3:0] db_player_position,
    output [3:0] db_new_obstacle,
    output [3:0] db_new_objective
);

reg [3:0] player_position;
reg [3:0] map_obstacles [0:15];
reg [3:0] map_objectives [0:15];
wire s_sel_obstacle, s_sel_objective, s_move_map, s_count_points;
wire [11:0] s_medida;
wire [1:0] s_velocity;
wire [63:0] s_map_obstacles_flat, s_map_objectives_flat;
wire s_obstacle_generated, s_objective_generated;
integer i;
integer k;

assign db_player_position = player_position;
assign db_new_obstacle = map_obstacles[15];
assign db_new_objective = map_objectives[15];


initial begin
    player_position <= 4'b1000; // Starting position
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        // Reset player position and map
        player_position <= 4'b1000;
        for (i = 0; i < 16; i = i + 1) begin
            map_obstacles[i] <= 4'b0000;
            map_objectives[i] <= 4'b0000;
        end
        game_over <= 1'b0;
    end else begin
        // Update player position based on button inputs
        if (botoes[0] && player_position != 4'b1000) player_position <= player_position << 1; // Move left
        else if (botoes[1] && player_position != 4'b0001) player_position <= player_position >> 1; // Move right
        
        // Check for obstacles
        if (map_obstacles[0] == player_position) begin
            game_over <= 1'b1; // Game over if player hits an obstacle
        end
    end
end

contador_m #(
    .M(30_000), // Every 30s
    .N(32)
) pontuacao_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_move_map),
    .Q (),
    .fim (s_count_points),
    .meio ()
);

contador_max #(
    .M(7),
    .N(3)
) velocity_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_count_points),
    .Q (pontuacao),
    .fim (),
    .meio ()
);

contador_m #(
    .M(3),
    .N(2)
) place_obstacle_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_move_map),
    .Q (),
    .fim (s_sel_obstacle),
    .meio ()
);

contador_m #(
    .M(6),
    .N(3)
) place_objective_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_move_map),
    .Q (),
    .fim (s_sel_objective),
    .meio ()
);

// Unflatten maps from generate_map
always @* begin
    for (k = 0; k < 16; k = k + 1) begin
        map_obstacles[k] = s_map_obstacles_flat[k*4 +: 4];
        map_objectives[k] = s_map_objectives_flat[k*4 +: 4];
    end
end

generate_map map_gen (
    .clock (clock),
    .reset (reset),
    .move_map (s_move_map),
    .sel_obstacle (s_sel_obstacle),
    .sel_objective (1'b0 /*s_sel_objective*/),
    .map_obstacles_flat (s_map_obstacles_flat),
    .map_objectives_flat (s_map_objectives_flat),
    .obstacle_generated (s_obstacle_generated),
    .objective_generated (s_objective_generated)
);

// Circuito de interface com sensor
interface_hcsr04 ultrassonico (
    .clock    (clock),
    .reset    (reset),
    .medir    (get_velocity),
    .echo     (echo),
    .trigger  (trigger),
    .medida   (s_medida),
    .pronto   (velocity_ready),
    .db_estado()
);

// Map velocity counters
assign s_velocity = (s_medida <= 12'h004) ? 2'b11 :
                    (s_medida <= 12'h008) ? 2'b10 :
                    (s_medida <= 12'h012) ? 2'b01 : 2'b00;

map_counter map_counter_inst (
    .clock (clock),
    .reset (reset),
    .count_map (count_map),
    .velocity (s_velocity),
    .move_map (s_move_map)
);

endmodule