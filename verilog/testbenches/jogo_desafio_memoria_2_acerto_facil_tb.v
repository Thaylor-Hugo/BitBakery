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

module jogo_desafio_memoria_2_acerto_facil_tb;

    // Sinais para conectar com o DUT
    // valores iniciais para fins de simulacao (ModelSim)
    reg        clock_in   = 1;
    reg        reset_in   = 0;
    reg        iniciar_in = 0;
    reg  [3:0] chaves_in  = 4'b0000;
    reg        botaoDificuldade_in = 0;
    reg        chaveMemoria_in = 1;

    wire       acertou_out;
    wire       errou_out  ;
    wire       pronto_out ; 
    wire [3:0] leds_out   ;

    wire       db_igual_out      ;
    wire [6:0] db_contagem_out   ;
    wire [6:0] db_memoria_out    ;
    wire [6:0] db_estado_out     ;
    wire [6:0] db_jogadafeita_out;
    wire [6:0] db_limite_out     ;
    wire       db_clock_out      ;
    wire       db_iniciar_out    ;
    wire       db_tem_jogada_out ;
    wire       db_timeout_out    ;
    wire       db_dificuldade_out;
    wire [1:0] db_selmux_out;
    wire       db_sel_memoria_out;

    // Configuração do clock
    parameter clockPeriod = 1_000_000; // in ns, f=1KHz

    // Identificacao do caso de teste
    reg [31:0] caso = 0;

    // Gerador de clock
    always #((clockPeriod / 2)) clock_in = ~clock_in;

    // instanciacao do DUT (Device Under Test)
    jogo_desafio_memoria dut (
        .clock          ( clock_in    ),
        .reset          ( reset_in    ),
        .jogar          ( iniciar_in  ),
        .chaveMemoria   (chaveMemoria_in),
        .botaoDificuldade (botaoDificuldade_in),
        .botoes         ( chaves_in   ),
        .leds           ( leds_out    ),
        .ganhou         ( acertou_out ),
        .perdeu         ( errou_out   ),
        .pronto         ( pronto_out  ),
        .timeout        ( db_timeout_out     ),
        .db_contagem    ( db_contagem_out    ),
        .db_memoria     ( db_memoria_out     ),
        .db_estado      ( db_estado_out      ),
        .db_jogadafeita ( db_jogadafeita_out ),
        .db_limite      ( db_limite_out      ),
        .db_clock       ( db_clock_out       ),
        .db_igual       ( db_igual_out       ),
        .db_iniciar     ( db_iniciar_out     ),    
        .db_tem_jogada  ( db_tem_jogada_out  ),
        .db_dificuldade ( db_dificuldade_out ),
        .db_sel_memoria ( db_sel_memoria_out),
        .db_selMux      ( db_selmux_out)
    );

    // geracao dos sinais de entrada (estimulos)
    initial begin
        $display("Inicio da simulacao");

        // condicoes iniciais
        caso       = 0;
        clock_in   = 1;
        reset_in   = 0;
        iniciar_in = 0;
        chaves_in  = 4'b0000;
        #clockPeriod;

        /*
        * Cenario de Teste exemplo - acerta 4 jogadas e erra a 5a jogada
        */

        // Teste 1. resetar circuito
        caso = 1;
        // gera pulso de reset
        @(negedge clock_in);
        reset_in = 1;
        #(clockPeriod);
        reset_in = 0;
        // espera
        #(10*clockPeriod);


        // Teste 2. aguardar por 10 periodos de clock
        caso = 2;
        #(10*clockPeriod);


        // Teste 3. iniciar=1 por 5 periodos de clock
        caso = 3;
        iniciar_in = 1;
        #(5*clockPeriod);
        iniciar_in = 0;
        // espera
        #(10*clockPeriod);

        // Teste 4. Rodada #0 - Chaves 0001
        caso = 4;
        @(negedge clock_in);
        #(1000*clockPeriod);
        #(500*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 5. Rodada #1 Todas as anteriores + chaves 0100
        caso = 5;
        @(negedge clock_in);
        #(2000*clockPeriod);
        #(500*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
    
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 6. Rodada #2 Todas as anteriores + chaves 0010
        caso = 6;
        @(negedge clock_in);
        #(3000*clockPeriod);
        #(500*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);

        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 7. Rodada #3 Todas as anteriores + chaves 1000
        caso = 7;
        @(negedge clock_in);
        #(4000*clockPeriod);
        #(500*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b1000;
        #(10*clockPeriod);

        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 8. Rodada #4 Todas as anteriores + chaves 0001
        caso = 8;
        @(negedge clock_in);
        #(2500*clockPeriod);
        #(2500*clockPeriod);
        #(500*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b1000;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);

        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 9. Rodada #5 Todas as anteriores + chaves 0100
        caso = 9;
        @(negedge clock_in);
        #(3000*clockPeriod);
        #(3000*clockPeriod);
        #(500*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b1000;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);

        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 10. Rodada #6 Todas as anteriores + chaves 0010
        caso = 10;
        @(negedge clock_in);
        #(3500*clockPeriod);
        #(3500*clockPeriod);
        #(500*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b1000;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);

        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 11. Rodada #7 Todas as anteriores + chaves 1000
        caso = 11;
        @(negedge clock_in);
        #(4000*clockPeriod);
        #(4000*clockPeriod);
        #(500*clockPeriod);
         chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b1000;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0001;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0100;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b0010;
        #(10*clockPeriod);
        chaves_in = 4'b0000;
        #(10*clockPeriod);
        chaves_in = 4'b1000;
        #(10*clockPeriod);

        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        
        chaves_in = 4'b0000;
        // espera entre jogadas
        #(10*clockPeriod);

        // Teste 20. Iniciar nova tentativa
        caso = 20;
        @(negedge clock_in);
        iniciar_in = 1;
        #(5*clockPeriod);
        iniciar_in = 0;
        // espera
        #(10*clockPeriod);
        
        // Teste 21. Resetar circuito
        caso = 21;
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
