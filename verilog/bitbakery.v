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
    input clock,
    input reset,
    input iniciar,
    input dificuldade,
    input [1:0] minigame,
    input [6:0] botoes,
    output [1:0] minigame_out,
    output [2:0] leds_out,
    output [3:0] estado_out,
    output [6:0] jogada_out,
    output [6:0] pontuacao_out,
    output [3:0] db_jogadas
);

parameter inicial = 2'b00;
parameter preparacao = 2'b01;
parameter execucao = 2'b10;
parameter fim = 2'b11;

wire s_pronto_0, s_pronto_1, s_pronto_2, s_pronto;
wire [2:0] s_leds_0, s_leds_1, s_leds_2;
wire [3:0] s_estado_0, s_estado_1, s_estado_2, s_estado_inicial;
wire [6:0] s_jogada_0, s_jogada_1, s_jogada_2;
wire [6:0] s_pontuacao_0, s_pontuacao_1, s_pontuacao_2;

reg [1:0] MiniGame, Eatual, Eprox;
reg Dificuldade, s_iniciar;

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
        preparacao: Eprox = (MiniGame != 2'b11)? execucao : preparacao;
        execucao: Eprox = s_pronto ? fim : execucao;
        fim: Eprox = iniciar ? preparacao : fim; 
        default: Eprox = inicial;
    endcase
end

// Lógica de saída
always @* begin
    s_iniciar <= (Eatual == preparacao)? 1'b1 : 1'b0;
    Dificuldade <= (Eatual == preparacao)? dificuldade : Dificuldade;
    MiniGame <= (Eatual == preparacao)? minigame : MiniGame;
end

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
    .pronto         (s_pronto_0),
    .db_jogada      (db_jogadas)
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
