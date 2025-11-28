// BUG: missed move_map signal depending on right change of velocity input

module map_counter (
    input clock,
    input clock_ultra,
    input reset,
    input count_map,
    input [1:0] velocity,
    output move_map,
    output pwm
);

wire s_move_map_800, s_move_map_700, s_move_map_600, s_move_map_500, s_move_map_400, s_move_map_300, s_move_map_200;
wire [1:0] s_base_velocity;
wire s_max_velocity, s_increment_velocity;

circuito_pwm #(
    .conf_periodo(1_000_000),
    .largura_000(35_000),
    .largura_001(45_700),
    .largura_010(56_450),
    .largura_011(67_150),
    .largura_100(77_850),
    .largura_101(88_550),
    .largura_110(99_300),
    .largura_111(110_000)
) velocimeter (
    .clock (clock_ultra),
    .reset (reset),
    .largura (s_base_velocity + velocity),
    .pwm (pwm),
    .db_pwm ()
);

velocity_mux velocity_selector (
    .v0 (s_move_map_800),
    .v1 (s_move_map_700),
    .v2 (s_move_map_600),
    .v3 (s_move_map_500),
    .v4 (s_move_map_400),
    .v5 (s_move_map_300),
    .v6 (s_move_map_200),
    .sel_base (s_base_velocity),
    .sel_player (velocity),
    .out (move_map)
);

contador_m #(
    .M(30_000), // 30 seconds at 1kHz
    .N(16)
) increment_velocity_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_increment_velocity),
    .meio ()
);

contador_max #(
    .M(4),
    .N(2)
) base_velocity_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_increment_velocity),
    .Q (s_base_velocity),
    .fim (s_max_velocity),
    .meio ()
);

// Timers divided by 8 to move map 8x faster (128 rows vs 16 rows = same visual speed)
contador_m #(
    .M(100), // 0.1 seconds at 1kHz (was 800ms / 8)
    .N(16)
) map_timer_800 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_800),
    .meio ()
);

contador_m #(
    .M(87), // ~0.087 seconds at 1kHz (was 700ms / 8)
    .N(16)
) map_timer_700 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_700),
    .meio ()
);

contador_m #(
    .M(75), // 0.075 seconds at 1kHz (was 600ms / 8)
    .N(16)
) map_timer_600 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_600),
    .meio ()
);

contador_m #(
    .M(62), // ~0.062 seconds at 1kHz (was 500ms / 8)
    .N(16)
) map_timer_500 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_500),
    .meio ()
);

contador_m #(
    .M(50), // 0.05 seconds at 1kHz (was 400ms / 8)
    .N(16)
) map_timer_400 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_400),
    .meio ()
);

contador_m #(
    .M(37), // ~0.037 seconds at 1kHz (was 300ms / 8)
    .N(16)
) map_timer_300 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_300),
    .meio ()
);

contador_m #(
    .M(25), // 0.025 seconds at 1kHz (was 200ms / 8)
    .N(16)
) map_timer_200 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_200),
    .meio ()
);

endmodule