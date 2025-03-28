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
    output [1:0] minigame_out,
    output [2:0] leds_out,
    output [3:0] estado_out,
    output [6:0] jogada_out,
    output [2:0] pontuacao_out,
	 output [6:0] db_estado,
	 output [1:0] db_minigame,
	 output [6:0] db_jogada,
	 output db_iniciar,
	 output db_clock
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
wire [2:0] s_leds_0, s_leds_1, s_leds_2;
wire [3:0] s_estado_0, s_estado_1, s_estado_2, s_estado_inicial;
wire [6:0] s_jogada_0, s_jogada_1, s_jogada_2;
wire [2:0] s_pontuacao_0, s_pontuacao_1, s_pontuacao_2;

reg [1:0] MiniGame; 
reg [2:0] Eatual, Eprox;
reg Dificuldade, s_iniciar;

assign db_clock = clock;
assign db_minigame = minigame_out;
assign db_iniciar = iniciar;
assign db_jogada = jogada_out;

hexa7seg display_state (
	.hexa (estado_out),
	.display (db_estado)
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
        preparacao: Eprox = (MiniGame != 2'b11 && MiniGame != 2'b10)? intervalo : preparacao;
        intervalo: Eprox = fim_intervalo ? start_game : intervalo;
        start_game: Eprox = execucao;
        execucao: Eprox = s_pronto ? fim : execucao;
        fim: Eprox = iniciar ? preparacao : fim; 
        default: Eprox = inicial;
    endcase
end


contador_m  #(.M(5000), .N(32)) contador_intervalo (
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
    Dificuldade <= (Eatual == preparacao)? dificuldade : Dificuldade;
    MiniGame <= (Eatual == preparacao)? minigame : MiniGame;
end

clock_diviser clock_out (
    .clock (clock_in),
    .clock_divised (clock)
);

mux_out saidas (
    .minigame       (MiniGame),
    .leds_0         (s_leds_0),
    .estado_0       (s_estado_0),
    .jogada_0       (s_jogada_0),
    .pronto_0       (s_pronto_0),
    .pontuacao_0    (s_pontuacao_0),
    .leds_1         (s_leds_1),
    .estado_1       (s_estado_1),
    .jogada_1       (s_jogada_1),
    .pronto_1       (s_pronto_1),
    .pontuacao_1    (s_pontuacao_1),
    .leds_2         (s_leds_2),
    .estado_2       (s_estado_2),
    .jogada_2       (s_jogada_2),
    .pronto_2       (s_pronto_2),
    .pontuacao_2    (s_pontuacao_2),
    .estado_inicial (s_estado_inicial),
    .leds_out       (leds_out),
    .estado_out     (estado_out),
    .jogada_out     (jogada_out),
    .pronto_out     (s_pronto),
    .pontuacao_out  (pontuacao_out)
);

jogo_desafio_memoria game0 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_0),
    .jogadas        (s_jogada_0),
    .leds           (s_leds_0),
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
    .leds           (s_leds_1),
    .pontuacao      (s_pontuacao_1),
    .pronto         (s_pronto_1)
);

clothesgame game2 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_2),
    .jogadas        (s_jogada_2),
    .leds           (s_leds_2),
    .pontuacao      (s_pontuacao_2),
    .pronto         (s_pronto_2)
);

assign s_estado_inicial = Eatual;
assign minigame_out = MiniGame;

endmodule
