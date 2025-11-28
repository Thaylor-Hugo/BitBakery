
module delivery_game_fd (
    input clock,
    input clock_ultra,
    input reset,
    input reset_ultrasonico,
    input [6:0] botoes,
    input echo,
    input count_map,
    input get_velocity,
    input reset_delay,
    input conta_delay,
    input reset_timeout,
    input conta_timeout,
    output end_delay,
    output velocity_timeout,
    output [2:0] pontuacao,
    output game_over,
    output pwm,
    output trigger,
    output velocity_ready,
    output [3:0] db_player_position,
    output [511:0] db_map_obstacle,
    output [511:0] db_map_objective,
    output [11:0] db_medida
);

reg [3:0] player_position;
wire s_sel_obstacle, s_sel_objective, s_move_map, s_count_points;
wire [11:0] s_medida;
wire [1:0] s_velocity;
wire [511:0] s_map_obstacles_flat, s_map_objectives_flat;
wire s_obstacle_generated, s_objective_generated;
integer i;
integer k;

wire s_move_left, s_move_right;

assign db_player_position = player_position;
assign db_map_obstacle = s_map_obstacles_flat;
assign db_map_objective = s_map_objectives_flat;
assign db_medida = s_medida;

initial begin
    player_position <= 4'b1000; // Starting position
end

edge_detector move_left (
    .clock (clock),
    .reset (reset),
    .sinal (botoes[1]),
    .pulso (s_move_left)
);
edge_detector move_right (
    .clock (clock),
    .reset (reset),
    .sinal (botoes[0]),
    .pulso (s_move_right)
);

always @(posedge clock or posedge reset) begin
    if (reset) begin
        // Reset player position and map
        player_position <= 4'b1000;
    end else begin
        // Update player position based on button inputs
        if (s_move_left && player_position != 4'b1000) player_position <= player_position << 1; // Move left
        else if (s_move_right && player_position != 4'b0001) player_position <= player_position >> 1; // Move right
    end
end

// Collision detection: check if player overlaps with any obstacle in first 24 rows (0-23)
wire [23:0] collision_checks;
wire [23:0] end_checks;
genvar c;
generate
    for (c = 0; c < 24; c = c + 1) begin : collision_gen
        assign collision_checks[c] = |(s_map_obstacles_flat[c*4 +: 4] & player_position);
        assign end_checks[c] = |(s_map_objectives_flat[c*4 +: 4] & player_position);
    end
endgenerate

assign game_over = |collision_checks | |end_checks; // Game over if any collision or end detected

// Points counter - now counts map moves (8x more frequent, so multiply threshold by 8)
// At ~100ms per move, 2400 moves = ~240 seconds gameplay per point
contador_m #(
    .M(240_000), // Every 30s equivalent (30_000 * 8 moves)
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

// Obstacle placement every 24 moves (was 3, now 3*8=24 to maintain same visual frequency)
contador_m #(
    .M(40),
    .N(6)
) place_obstacle_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_move_map),
    .Q (),
    .fim (s_sel_obstacle),
    .meio ()
);

// Objective placement every 90 seconds
contador_m #(
    .M(90_000),
    .N(32)
) place_objective_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_sel_objective),
    .meio ()
);

generate_map map_gen (
    .clock (clock),
    .reset (reset),
    .move_map (s_move_map),
    .sel_obstacle (s_sel_obstacle),
    .sel_objective (s_sel_objective),
    .map_obstacles_flat (s_map_obstacles_flat),
    .map_objectives_flat (s_map_objectives_flat),
    .obstacle_generated (s_obstacle_generated),
    .objective_generated (s_objective_generated)
);

// Circuito de interface com sensor
interface_hcsr04 ultrassonico (
    .clock    (clock_ultra),
    .reset    (reset_ultrasonico),
    .medir    (get_velocity),
    .echo     (echo),
    .trigger  (trigger),
    .medida   (s_medida),
    .pronto   (velocity_ready),
    .db_estado()
);

contador_m #(
    .M(1000),
    .N(32)
) velocity_delay (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset_delay),
    .conta (conta_delay),
    .Q (),
    .fim (end_delay),
    .meio ()
);

contador_m #(
    .M(5),
    .N(5)
) velocity_timeout_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset_timeout),
    .conta (conta_timeout),
    .Q (),
    .fim (velocity_timeout),
    .meio ()
);

// Map velocity counters
assign s_velocity = (s_medida <= 12'h006) ? 2'b11 :
                    (s_medida <= 12'h012) ? 2'b10 :
                    (s_medida <= 12'h018) ? 2'b01 : 2'b00;

map_counter map_counter_inst (
    .clock (clock),
    .clock_ultra (clock_ultra),
    .reset (reset),
    .count_map (count_map),
    .velocity (s_velocity),
    .move_map (s_move_map),
    .pwm (pwm)
);

endmodule
