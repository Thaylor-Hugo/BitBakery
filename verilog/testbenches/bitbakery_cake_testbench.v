/* --------------------------------------------------------------------
 * Arquivo   : circuito_exp6_acerto_tb.v
 * Projeto   : Experiencia 6 - Desenvolvimento de Projeto de 
 *             Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : testbench Verilog alterado para circuito da Experiencia 5 
 *              baseado no modelo fornecido
 *
 *             1) Plano de teste com todas jogadas certas
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     27/01/2024  1.0     Edson Midorikawa  versao inicial
 *     16/01/2024  1.1     Edson Midorikawa  revisao
 *     25/01/2025  1.2     T5BB5             revisao
 * --------------------------------------------------------------------
 */

`timescale 1ns/1ns

module bitbakery_cake_testbench;

    // Sinais para conectar com o DUT
    // valores iniciais para fins de simulacao (ModelSim)
    reg clock_in = 0;
    reg reset_in = 1;
    reg iniciar_in = 1;
    reg dificuldade = 0;
    reg [1:0] minigame = 2'b01; // CakeGame
    reg [6:0] botoes_in = 7'b1111111;

    wire [1:0] minigame_out;
    wire [2:0] leds_out;
    wire [3:0] estado_out;
    wire [6:0] jogada_out;
    wire [2:0] pontuacao_out;
    wire [6:0] db_estado;
    wire [1:0] db_minigame;
    wire [6:0] db_jogada;
    wire db_iniciar;
    wire db_clock;  
    
    // Configuração do clock
    parameter clockPeriod = 1_000_000; // in ns, f=1KHz

    // Identificacao do caso de teste
    reg [31:0] caso = 0;

    // Gerador de clock
    always #((clockPeriod / 2)) clock_in = ~clock_in;

    // instanciacao do DUT (Device Under Test)
    bitbakery dut (
        .clock_in (clock_in),
        .reset_in (reset_in),
        .iniciar_in (iniciar_in),
        .dificuldade (dificuldade),
        .minigame (minigame),
        .botoes_in (botoes_in),
        .minigame_out (minigame_out),
        .leds_out (leds_out),
        .estado_out (estado_out),
        .jogada_out (jogada_out),
        .pontuacao_out (pontuacao_out),
        .db_estado (db_estado),
        .db_minigame (db_minigame),
        .db_jogada (db_jogada),
        .db_iniciar (db_iniciar),
        .db_clock (db_clock)
    );

    // geracao dos sinais de entrada (estimulos)
    initial begin
        $display("Inicio da simulacao");

        // condicoes iniciais
        caso       = 0;
        clock_in   = 1;
        reset_in   = 1;
        iniciar_in = 1;
        botoes_in  = 7'b1111111;
        #clockPeriod;

        /*
        * Cenario de Teste exemplo
        */

        // Teste 1. resetar circuito
        caso = 1;
        // gera pulso de reset
        @(negedge clock_in);
        reset_in = 0;
        #(clockPeriod);
        reset_in = 1;
        // espera
        #(10*clockPeriod);


        // Teste 2. aguardar por 10 periodos de clock
        caso = 2;
        #(10*clockPeriod);


        // Teste 3. iniciar=1 por 5 periodos de clock
        caso = 3;
        iniciar_in = 0;
        #(5*clockPeriod);
        iniciar_in = 1;
        // espera
        #(10*clockPeriod);

        // Teste 4. Mostra Jogada gabarito
        caso = 4;
        @(negedge clock_in);
        #(4000*clockPeriod);
        #(4000*clockPeriod);
        #(4000*clockPeriod);
        #(4000*clockPeriod);
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 5. Joga 16 vezes
        caso = 5;
        @(negedge clock_in);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        botoes_in = 7'b1111110;
        #(10*clockPeriod);
        botoes_in = 7'b1111111;
        #(10*clockPeriod);
        // espera entre jogadas
        #(10*clockPeriod);
        #(10*clockPeriod);
        
        // Teste 6. Iniciar nova tentativa
        caso = 6;
        @(negedge clock_in);
        iniciar_in = 1;
        #(5*clockPeriod);
        iniciar_in = 0;
        // espera
        #(10*clockPeriod);
        
        // Teste 21. Resetar circuito
        caso = 7;
        @(negedge clock_in);
        reset_in = 1;
        #(5*clockPeriod);
        reset_in = 0;
        // espera
        #(10*clockPeriod);

        // final dos casos de teste da simulacao
        caso = 99;
        #100;
        $display("Fim da simulacao");
        $stop;
    end

  endmodule
