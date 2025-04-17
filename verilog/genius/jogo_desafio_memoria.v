//------------------------------------------------------------------
// Arquivo   : circuito_exp5.v
// Projeto   : Experiencia 5 - Projeto de um Sistema Digital 
//------------------------------------------------------------------
// Descricao : Modulo principal da experiencia
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor            Descricao
//     18/01/2025  1.0     T5BB5            versao inicial
//------------------------------------------------------------------
//

module jogo_desafio_memoria (
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

wire [3:0] s_contagem, s_estado, s_limite;
wire [6:0] s_botoes, s_memoria;
wire [1:0] s_selMux;
wire s_fimE, s_fimL, s_botoes_igual_memoria,s_meioL, s_dificuldade, s_zeraE, s_zeraL, s_contaE, s_contaL;
wire s_zeraR, s_registraR, s_jogada, s_timeout, s_contaT, s_endereco_igual_limite, s_endereco_menor_limite;
wire s_zeraM, s_contaM, s_meioM, s_fimM, s_sel_memoria, s_reset_random;
wire [6:0] s_jogadas;

wire s_ganhou, s_perdeu, s_fim_timeout;
assign pontuacao = 2'b0;
assign estado = s_estado;
assign jogadas = s_jogadas;

unidade_controle controlUnit (
    .clock                  (clock),
    .reset                  (reset),
    .iniciar                (jogar),
    .jogada                 (s_jogada),
	.timeout                (s_timeout),
    .botoesIgualMemoria     (s_botoes_igual_memoria),
    .fimE                   (s_fimE),
    .fimL                   (s_fimL),
	.meioL					(s_meioL),
    .enderecoIgualLimite    (s_endereco_igual_limite),
    .enderecoMenorLimite    (s_endereco_menor_limite),
    .zeraE                  (s_zeraE),
    .contaE                 (s_contaE),
    .zeraL                  (s_zeraL),
    .contaL                 (s_contaL),
    .zeraR                  (s_zeraR),
    .registraR              (s_registraR),
    .acertou                (s_ganhou),
    .errou                  (s_perdeu),
    .pronto                 (pronto),
    .fim_timeout            (s_fim_timeout),
    .db_estado              (s_estado),
	.contaT                 (s_contaT),
	.db_dificuldade 		(s_dificuldade),
	.chaveDificuldade		(dificuldade),
    .seletor                (s_selMux),
    .zeraM                  (s_zeraM),
    .contaM                 (s_contaM),
    .meioM                  (s_meioM),
    .seletorMemoria			(s_sel_memoria),
    .reset_random           (s_reset_random),
    .fimM                   (s_fimM)
);

fluxo_dados fluxo_dados (
    .clock                  (clock),
    .zeraE                  (s_zeraE),
    .contaE                 (s_contaE),
    .zeraL                  (s_zeraL),
    .contaL                 (s_contaL),
    .zeraR                  (s_zeraR),
    .registraR              (s_registraR),
    .botoes                 (botoes),
    .selecionaMemoria		(s_sel_memoria),
    .reset_random           (s_reset_random),
    .contaT                 (s_contaT),
    .botoesIgualMemoria     (s_botoes_igual_memoria),
    .fimE                   (s_fimE),
    .fimL                   (s_fimL),
    .meioL 					(s_meioL),
    .endecoIgualLimite      (s_endereco_igual_limite),
    .endecoMenorLimite      (s_endereco_menor_limite),
    .jogada_feita           (s_jogada),
    .db_limite              (s_limite),
    .db_contagem            (s_contagem),
    .db_memoria             (s_memoria),
    .db_jogada              (s_botoes),
	.timeout                (s_timeout),
    .leds                   (s_jogadas),	
    .seletor                (s_selMux),
    .zeraM                  (s_zeraM),
    .contaM                 (s_contaM),
    .meioM                  (s_meioM),
    .fimM                   (s_fimM)
);

endmodule