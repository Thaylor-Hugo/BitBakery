// Delivery Game Module

module delivery_game (
    input clock,
    input clock_ultra,
    input reset,
    input jogar,
    input dificuldade,
    input [6:0] botoes,
    input echo,
    output [3:0] estado,
    output [2:0] pontuacao,
    output pronto,
    output pwm,
    output trigger,
    output [3:0] db_player_position,
    output [511:0] db_map_obstacle,
    output [511:0] db_map_objective,
    output [11:0] db_medida
);

wire s_reset, s_game_over, s_count_map, s_get_velocity, s_velocity_ready, s_end_delay, s_conta_delay, s_reset_delay;
wire s_reset_timeout, s_conta_timeout, s_velocity_timeout, s_reset_ultrasonico;

delivery_game_fd fd (
    .clock (clock),
    .clock_ultra (clock_ultra),
    .reset (s_reset),
    .reset_ultrasonico (s_reset_ultrasonico),
    .botoes(botoes),
    .dificuldade(dificuldade),
    .echo (echo),
    .count_map (s_count_map),
    .get_velocity (s_get_velocity),
    .pontuacao (pontuacao),
    .game_over (s_game_over),
    .pwm (pwm),
    .trigger (trigger),
    .velocity_ready (s_velocity_ready),
    .db_player_position (db_player_position),
    .db_map_obstacle (db_map_obstacle),
    .db_map_objective (db_map_objective),
    .db_medida (db_medida),
    .reset_delay (s_reset_delay),
    .conta_delay (s_conta_delay),
    .end_delay (s_end_delay),
    .reset_timeout (s_reset_timeout),
    .conta_timeout (s_conta_timeout),
    .velocity_timeout (s_velocity_timeout)
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
    .get_velocity (s_get_velocity),
    .reset_delay (s_reset_delay),
    .conta_delay (s_conta_delay),
    .end_delay (s_end_delay),
    .reset_timeout (s_reset_timeout),
    .conta_timeout (s_conta_timeout),
    .velocity_timeout (s_velocity_timeout),
    .reset_ultrasonico (s_reset_ultrasonico)
);


endmodule