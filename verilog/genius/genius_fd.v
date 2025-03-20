//------------------------------------------------------------------
// Arquivo   : exp3_fluxo_dados.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle 
//------------------------------------------------------------------
// Descricao : Modulo do fluxo de dados da experiencia
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor            Descricao
//     18/01/2025  1.0     T5BB5            versao inicial
//------------------------------------------------------------------
//

module fluxo_dados (
    input clock,
    input zeraE,
    input contaE,
    input zeraL,
    input contaL,
    input zeraR,
    input zeraM,
    input contaM,
    input registraR,
	 input selecionaMemoria,
    input [3:0] botoes,
	 input contaT,
    input [1:0] seletor,
    output botoesIgualMemoria,
    output fimE,
    output fimL,
	output meioL,
    output fimM,
    output meioM,
    output endecoIgualLimite,
    output endecoMenorLimite,
    output jogada_feita,
    output db_tem_jogada,
    output [3:0] db_limite,
    output [3:0] db_contagem,
    output [3:0] db_memoria,
    output [3:0] db_jogada,
    output [3:0] leds,
	output timeout

);
    wire [3:0] s_endereco, s_dado, s_dado2, s_saida_memorias, s_botoes, s_limite, s_leds;  // sinal interno para interligacao dos componentes
    wire s_jogada;
    wire sinal = botoes[0] | botoes[1] | botoes[2] | botoes[3];


    // multiplexador 3x1
    mux3x1 mux (

        .D0      (4'b0),
        .D1      (s_saida_memorias),
        .D2      (botoes),
        .SEL     (seletor),
        .OUT     (s_leds)

    );
	 
	 mux2x1 mux_memorias (

        .D0      (s_dado),
        .D1      (s_dado2),
        .SEL     (selecionaMemoria),
        .OUT     (s_saida_memorias)
    );


    // contador_163
    contador_163 contador (
        .clock    (clock),
        .clr      (~zeraE),
        .ld       (1'b1),
        .ent      (1'b1),
        .enp      (contaE),
        .D        (4'b0),
        .Q        (s_endereco),
        .rco      (fimE)
    );

   
	 
	 // contador_m
    contador_m  #(.M(16),.N(4)) contadorLmt (
       .clock     (clock),   
       .zera_as   (zeraL),
       .zera_s    (1'b0),
       .conta	  (contaL),
       .Q         (s_limite),
       .fim       (fimL),
       .meio      (meioL)
    );

    // contador_m
    contador_m  #(.M(50000000),.N(32)) contadorM (
       .clock     (clock),   
       .zera_as   (zeraM),
       .zera_s    (1'b0),
       .conta	  (contaM),
       .Q         (),
       .fim       (fimM),
       .meio      (meioM)
    );
	 
	 // contador_m
    contador_m  #(.M(200000000), .N(64)) contador_timeout (
       .clock     (clock),   
       .zera_as   (~contaT),
       .zera_s    (1'b0),
       .conta	   (contaT),
       .Q         (),
       .fim       (timeout),
       .meio      ()
    );

     // edge_detector
    edge_detector detector (
        .clock      (clock), 
        .reset      (zeraL),
        .sinal      (sinal),
        .pulso      (s_jogada)
    );

    // memoria_rom_16x4
    sync_rom_16x4 rom (
        .clock      (clock),
        .address    (s_endereco),
        .data_out   (s_dado)
    );
	 
	 sync_rom_16x4_mem2 rom_2 (
        .clock      (clock),
        .address    (s_endereco),
        .data_out   (s_dado2)
    );
	 
	 

    // registrador de 4 bits
    registrador_4 registrador (
        .clock  (clock),
        .clear  (zeraR),
        .enable (registraR),
        .D      (botoes),
        .Q      (s_botoes)
    );

    // comparador_85
    comparador_85 comparador (
        .A    (s_saida_memorias),
        .B    (s_botoes),
        .ALBi (1'b0),
        .AGBi (1'b0),
        .AEBi (1'b1),
        .ALBo (    ),
        .AGBo (    ),
        .AEBo (botoesIgualMemoria)
    );
    
    // comparador_85
    comparador_85 comparadorLmt (
        .A    (s_endereco),
        .B    (s_limite),
        .ALBi (1'b0),
        .AGBi (1'b0),
        .AEBi (1'b1),
        .ALBo (endecoMenorLimite),
        .AGBo (    ),
        .AEBo (endecoIgualLimite)
    );

    // saida de depuracao
    assign db_contagem = s_endereco;
    assign db_memoria = s_saida_memorias;
    assign db_jogada = s_botoes;
    assign jogada_feita = s_jogada;
    assign db_tem_jogada = sinal;
    assign db_limite = s_limite;
    assign leds = s_leds;

 endmodule
