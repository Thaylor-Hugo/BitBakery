
module delivery_game_fd (
    input clock,
    input clock_ultra,
    input reset,
    input [6:0] botoes,
    input echo,
    input count_map,
    input get_velocity,
    input reset_delay,
    input conta_delay,
    output end_delay,
    output [2:0] pontuacao,
    output game_over,
    output pwm,
    output trigger,
    output velocity_ready,
    output [3:0] db_player_position,
    output [63:0] db_map_obstacle,
    output [63:0] db_map_objective,
    output [11:0] db_medida
);

reg [3:0] player_position;
wire s_sel_obstacle, s_sel_objective, s_move_map, s_count_points;
wire [11:0] s_medida;
wire [1:0] s_velocity;
wire [63:0] s_map_obstacles_flat, s_map_objectives_flat;
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
    .sinal (botoes[0]),
    .pulso (s_move_left)
);
edge_detector move_right (
    .clock (clock),
    .reset (reset),
    .sinal (botoes[1]),
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

assign game_over = ((s_map_obstacles_flat[3:0] & player_position) == 4'h0)? 1'b0 : 1'b1;

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
    .clock    (clock_ultra),
    .reset    (reset),
    .medir    (get_velocity),
    .echo     (echo),
    .trigger  (trigger),
    .medida   (s_medida),
    .pronto   (velocity_ready),
    .db_estado()
);

contador_m #(
    .M(32),
    .N(500)
) velocity_delay (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset_delay),
    .conta (conta_delay),
    .Q (),
    .fim (end_delay),
    .meio ()
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
    .move_map (s_move_map),
    .pwm (pwm)
);

endmodule
