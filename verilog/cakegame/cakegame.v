
module cakegame (
    input clock,
    input reset,
    input jogar,
    input dificuldade,
    input [6:0] botoes,
    output [6:0] jogadas,
    output [3:0] estado,
    output [2:0] pontuacao,
    output pronto
);

wire [1:0] s_out_sel;
wire [3:0] s_estado;
wire s_clear_reg, s_enable_reg, s_clear_mem_counter, s_enable_mem_counter, s_clear_show_counter, s_enable_show_counter, s_enable_timeout_counter, s_clear_points_counter, s_enable_points_counter, s_end_mem_counter, s_correct_play, s_has_play, s_end_show, s_half_show, s_timeout, s_pronto;
wire clear_ram, enable_ram;

cakegame_fd data_flux(
    .clock                  (clock),
    .buttons                (botoes),
    .out_sel                (s_out_sel),
    .dificuldade            (dificuldade),
    .clear_reg              (s_clear_reg),
    .enable_reg             (s_enable_reg),
    .clear_mem_counter      (s_clear_mem_counter),
    .enable_mem_counter     (s_enable_mem_counter),
    .clear_show_counter     (s_clear_show_counter),
    .enable_show_counter    (s_enable_show_counter),
    .enable_timeout_counter (s_enable_timeout_counter),
    .clear_points_counter   (s_clear_points_counter),
    .enable_points_counter  (s_enable_points_counter),
    .clear_ram              (clear_ram),
    .enable_ram             (enable_ram),
    .reset_random           (reset_random),
    .end_mem_counter        (s_end_mem_counter),
    .correct_play           (s_correct_play),
    .has_play               (s_has_play),
    .end_show               (s_end_show),
    .half_show              (s_half_show),
    .timeout                (s_timeout),
    .play                   (jogadas),
    .points                 (pontuacao)
);

cakegame_uc control_unit(
    .clock                  (clock),
    .reset                  (reset),
    .start                  (jogar),
    .end_mem_counter        (s_end_mem_counter),
    .correct_play           (s_correct_play),
    .has_play               (s_has_play),
    .end_show               (s_end_show),
    .half_show              (s_half_show),
    .timeout                (s_timeout),
    .out_sel                (s_out_sel),
    .clear_reg              (s_clear_reg),
    .enable_reg             (s_enable_reg),
    .clear_mem_counter      (s_clear_mem_counter),
    .enable_mem_counter     (s_enable_mem_counter),
    .clear_show_counter     (s_clear_show_counter),
    .enable_show_counter    (s_enable_show_counter),
    .enable_timeout_counter (s_enable_timeout_counter),
    .clear_points_counter   (s_clear_points_counter),
    .enable_points_counter  (s_enable_points_counter),
    .clear_ram              (clear_ram),
    .enable_ram             (enable_ram),
    .reset_random           (reset_random),
    .finished               (pronto),
    .state                  (s_estado)
);

assign estado = s_estado;

endmodule
