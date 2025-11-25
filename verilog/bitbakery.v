//------------------------------------------------------------------
// Arquivo   : bitbakery.v
// Projeto   : BitBakery
//------------------------------------------------------------------
// Descricao : BitBakery Top Module
//
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/03/2025  1.0     T5BB5             versao inicial
//------------------------------------------------------------------
//

module bitbakery (
    input clock_in,
    input reset_in,
    input iniciar_in,
    input dificuldade,
    input [1:0] minigame,
    input [6:0] botoes_in,
    input echo,
    output saida_serial,
    output pwm,
    output db_pwm,
    output db_echo,
    output db_trigger,
    output trigger,
    output [2:0] pontuacao_out,
    output [6:0] db_estado,
    output [1:0] db_minigame,
    output [6:0] db_jogada,
    output db_iniciar,
	output db_clock,
    output db_dificuldade,
    // output [3:0] db_player_position,
    // output [63:0] db_map_objective,
    // output [15:0] db_map_obstacle,
    output [6:0] cm0,
    output [6:0] cm1,
    output [6:0] db_botoes,
    output db_serial
);

parameter inicial = 3'b000;
parameter preparacao = 3'b001;
parameter execucao = 3'b010;
parameter fim = 3'b011;
parameter intervalo = 3'b100;
parameter start_game = 3'b101;

wire reset, iniciar, clock;
wire [6:0] botoes;
assign iniciar = ~iniciar_in;
assign reset = ~reset_in;
assign botoes = ~botoes_in;

wire s_pronto_0, s_pronto_1, s_pronto_2, s_pronto, fim_intervalo;
wire [3:0] s_estado_0, s_estado_1, s_estado_2, s_estado_inicial, s_estado;
wire [6:0] s_jogada_0, s_jogada_1, s_jogada_2;
wire [2:0] s_pontuacao_0, s_pontuacao_1, s_pontuacao_2;
wire [3:0] estado_out;
wire [3:0] s_player_position;
wire [63:0] s_map_objective, s_map_obstacle;
wire [11:0] db_medida;

reg [1:0] MiniGame; 
reg [2:0] Eatual, Eprox;
reg Dificuldade, s_iniciar;

assign db_clock = clock;
assign db_minigame = MiniGame;
assign db_iniciar = iniciar;
assign estado_out = (Eatual == intervalo)? 4'b0001 : s_estado;
assign db_dificuldade = Dificuldade;
assign db_botoes = botoes_in;

// assign db_map_objective = s_map_objective[15:0];
// assign db_map_obstacle = s_map_obstacle[15:0];
// assign db_player_position = s_player_position;
assign db_serial = saida_serial;

hexa7seg display_state (
	.hexa (estado_out),
	.display (db_estado)
);

hexa7seg display_cm0 (
    .hexa (db_medida[3:0]),
    .display (cm0)
);

hexa7seg display_cm1 (
    .hexa (db_medida[7:4]),
    .display (cm1)
);

initial begin
    MiniGame <= 2'b11;
    Dificuldade <= 1'b0;
    Eatual <= 2'b00;
    Eprox <= 2'b00;
end

always @(posedge clock or posedge reset) begin
    if (reset)
        Eatual <= inicial;
    else
        Eatual <= Eprox;
end

// Máquina de estados
always @* begin
    case (Eatual)
        inicial: Eprox = iniciar ? preparacao : inicial;
        preparacao: Eprox = (MiniGame != 2'b11)? intervalo : preparacao;
        intervalo: Eprox = fim_intervalo ? start_game : intervalo;
        start_game: Eprox = execucao;
        execucao: Eprox = s_pronto ? fim : execucao;
        fim: Eprox = iniciar ? preparacao : fim; 
        default: Eprox = inicial;
    endcase
end


contador_m  #(.M(2000), .N(32)) contador_intervalo (
    .clock      (clock),   
    .zera_as    (Eatual == iniciar),
    .zera_s     (1'b0),
    .conta	    (Eatual == intervalo),
    .Q          (),
    .fim        (fim_intervalo),
    .meio       ()
);

// Lógica de saída
always @* begin
    s_iniciar <= (Eatual == start_game)? 1'b1 : 1'b0;
    Dificuldade <= (Eatual == preparacao || Eatual == inicial)? dificuldade : Dificuldade;
    MiniGame <= (Eatual == preparacao || Eatual == inicial)? minigame : MiniGame;
end

assign pontuacao_out = {Dificuldade, 1'b0, 1'b0};

clock_diviser clock_out (
    .clock (clock_in),
    .clock_divised (clock)
);

mux_out saidas (
    .minigame       (MiniGame),
    .estado_0       (s_estado_0),
    .jogada_0       (s_jogada_0),
    .pronto_0       (s_pronto_0),
    .pontuacao_0    (s_pontuacao_0),
    .estado_1       (s_estado_1),
    .jogada_1       (s_jogada_1),
    .pronto_1       (s_pronto_1),
    .pontuacao_1    (s_pontuacao_1),
    .estado_2       (s_estado_2),
    .jogada_2       (s_jogada_2),
    .pronto_2       (s_pronto_2),
    .pontuacao_2    (s_pontuacao_2),
    .estado_inicial (s_estado_inicial),
    .estado_out     (s_estado),
    .jogada_out     (db_jogada),
    .pronto_out     (s_pronto),
    .pontuacao_out  ()
);

// assign s_estado = s_estado_1;
// assign db_jogada = s_jogada_1;
// assign s_pronto = s_pronto_1;

jogo_desafio_memoria game0 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (~Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_0),
    .jogadas        (s_jogada_0),
    .pontuacao      (s_pontuacao_0),
    .pronto         (s_pronto_0)
);

cakegame game1 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_1),
    .jogadas        (s_jogada_1),
    .pontuacao      (s_pontuacao_1),
    .pronto         (s_pronto_1)
);

delivery_game game3 (
    .clock (clock),
    .reset (reset),
    .jogar (s_iniciar),
    .botoes (botoes),
    .echo (echo),
    .estado (s_estado_2),
    .pontuacao (s_pontuacao_2),
    .pronto (s_pronto_2),
    .pwm (pwm),
    .trigger (trigger),
    .db_player_position (s_player_position),
    .db_map_obstacle (s_map_obstacle),
    .db_map_objective (s_map_objective),
    .db_medida (db_medida)
);

bitbakery_serial_tx serial_tx (
    .clock          (clock_in     ),  // Use 50MHz clock directly, not divided clock!
    .reset          (reset        ),
    .D0             ({2'b00, MiniGame, estado_out}),
    .D1             ({2'b01, db_jogada[5:0]}),
    .D2             ({2'b10, 1'b0, db_dificuldade, s_player_position}),
    .map_obstacles  (s_map_obstacle),
    .saida_serial   (saida_serial )
);

assign s_estado_inicial = Eatual;

endmodule
