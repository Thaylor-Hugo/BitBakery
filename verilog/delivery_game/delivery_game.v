// Delivery Game Module

module delivery_game (
    input clock,
    input reset,
    input jogar,
    input [6:0] botoes,
    input echo,
    output [3:0] estado,
    output [2:0] pontuacao,
    output pronto,
    output pwm,
    output trigger,
    output [3:0] db_player_position,
    output [3:0] db_new_obstacle,
    output [3:0] db_new_objective
);

wire s_reset, s_game_over, s_count_map, s_get_velocity, s_velocity_ready;

delivery_game_fd fd (
    .clock (clock),
    .reset (s_reset),
    .botoes(botoes),
    .echo (echo),
    .count_map (s_count_map),
    .get_velocity (s_get_velocity),
    .pontuacao (pontuacao),
    .game_over (s_game_over),
    .pwm (pwm),
    .trigger (trigger),
    .velocity_ready (s_velocity_ready),
    .db_player_position (db_player_position),
    .db_new_obstacle (db_new_obstacle),
    .db_new_objective (db_new_objective)
);

delivery_game_uc uc (
    .clock (clock),
    .reset (reset),
    .jogar (jogar),
    .game_over (s_game_over),
    .velocity_ready (s_velocity_ready),
    .estado (estado),
    .reset_out (s_reset),
    .pronto (pronto),
    .count_map (s_count_map),
    .get_velocity (s_get_velocity)
);


endmodule