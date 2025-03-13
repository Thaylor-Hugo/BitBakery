//------------------------------------------------------------------
// Arquivo   : exp3_unidade_controle.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
//------------------------------------------------------------------
// Descricao : Unidade de controle
//
// usar este codigo como template (modelo) para codificar 
// máquinas de estado de unidades de controle            
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/01/2024  1.0     Edson Midorikawa  versao inicial
//     12/01/2025  1.1     Edson Midorikawa  revisao
//------------------------------------------------------------------
//

module unidade_controle (
    input clock,
    input reset,
    input iniciar,
    input jogada,
	input timeout,
    input botoesIgualMemoria,
    input fimE,
    input fimL,
	input chaveMemoria,
	input meioL,
    input enderecoIgualLimite,
    input enderecoMenorLimite,
	input chaveDificuldade,
    input [1:0] chaveMinigame,
    input fimM,
    input meioM,
    output reg [1:0] seletor,
    output reg zeraM,
    output reg contaM,
    output reg zeraE,
    output reg contaE,
    output reg zeraL,
    output reg contaL,
    output reg zeraR,
    output reg registraR,
    output reg acertou,
    output reg errou,
    output reg pronto,
    output reg fim_timeout,
    output reg [3:0] db_estado,
	output reg contaT,
	output  seletorMemoria,
	output  db_dificuldade
);

    // Defini Minigames
    parameter genius = 2'b00;
    parameter bolo = 2'b01;
    parameter roupas = 2'b10;

    // Define estados
    parameter inicial               = 6'b000000;  // 0
    parameter preparacao            = 6'b000001;  // 1
    parameter escolhe_jogo          = 6'b000010;  // 2

    // Genius 6'b01xxxx
    parameter genius_proxima_mostra        = 6'b010000;  // 16 0x10  
    parameter genius_espera_jogada         = 6'b010001;  // 17 0x11
    parameter genius_registra_jogada       = 6'b010010;  // 18 0x12
    parameter genius_compara_jogada        = 6'b010011;  // 19 0x13
    parameter genius_proxima_jogada        = 6'b010100;  // 20 0x14
    parameter genius_foi_ultima_sequencia  = 6'b010101;  // 21 0x15
    parameter genius_proxima_sequencia     = 6'b010110;  // 22 0x16
    parameter genius_mostra_jogada         = 6'b010111;  // 23 0x17
    parameter genius_intervalo_mostra      = 6'b011000;  // 24 0x18
    parameter genius_inicia_sequencia      = 6'b011001;  // 25 0x19
	parameter genius_intervalo_rodada      = 6'b011010;  // 26 0x1A
    parameter genius_final_timeout 	       = 6'b011011;  // 27 0x1B
    parameter genius_final_acertou         = 6'b011100;  // 28 0x1C
    parameter genius_final_errou           = 6'b011101;  // 29 0x1D

    // bolo 6'b10xxxx

    // Roupas 6'b11xxxx
	 

    // Variaveis de estado
    reg [5:0] Eatual, Eprox;
	reg Dificuldade, Memoria;
    reg [1:0] Minigame;

    initial begin
        Eatual = inicial;
		  Dificuldade = 1'b0;
		  Memoria = 1'b0;
          Minigame = 2'b00;
    end

    // Memoria de estado
    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    // Logica de proximo estado
    always @* begin
        case (Eatual)
            inicial:          Eprox <= iniciar ? preparacao : inicial;
            preparacao:       Eprox <= genius_mostra_jogada;


            // Genius Game
            genius_mostra_jogada:    Eprox <= meioM ? genius_intervalo_mostra : genius_mostra_jogada;
            genius_intervalo_mostra: Eprox <= fimM ? genius_proxima_mostra : genius_intervalo_mostra;
            genius_proxima_mostra:   Eprox <= enderecoIgualLimite ? genius_inicia_sequencia : genius_mostra_jogada;
            genius_inicia_sequencia: Eprox <= genius_espera_jogada;
            genius_espera_jogada:    begin 
                if (jogada) begin
					Eprox <= genius_registra_jogada;
				end else if (timeout) begin
					Eprox <= genius_final_timeout;
				end else begin
					Eprox <= genius_espera_jogada;
				end
            end													
            genius_registra_jogada:  Eprox <= genius_compara_jogada;
            genius_compara_jogada:   begin 
                if (enderecoMenorLimite && botoesIgualMemoria) begin
					Eprox <= genius_proxima_jogada;
				end else if (enderecoIgualLimite && botoesIgualMemoria) begin
					Eprox <= genius_foi_ultima_sequencia ;
				end else begin
					Eprox <= genius_final_errou;
				end
            end													
            genius_proxima_jogada:         Eprox <= genius_espera_jogada;
            genius_foi_ultima_sequencia:   Eprox <= (fimL || (meioL && ~Dificuldade)) ? genius_final_acertou : genius_intervalo_rodada;
			genius_intervalo_rodada:       Eprox <= meioM ? genius_proxima_sequencia : genius_intervalo_rodada;
            genius_proxima_sequencia:      Eprox <= genius_mostra_jogada;
            genius_final_timeout:          Eprox <= iniciar ? preparacao : genius_final_timeout;
            genius_final_errou:            Eprox <= iniciar ? preparacao : genius_final_errou;
            genius_final_acertou:          Eprox <= iniciar ? preparacao : genius_final_acertou;


            // Bolo Game

            // Roupas Game
            default:                Eprox <= inicial;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        if (Minigame == genius) begin
            zeraL     	<= (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
            zeraR     	<= (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
            zeraE     	<= (Eatual == inicial || Eatual == preparacao || Eatual == genius_proxima_sequencia || Eatual == genius_inicia_sequencia) ? 1'b1 : 1'b0;
            registraR 	<= (Eatual == genius_registra_jogada) ? 1'b1 : 1'b0;
            contaL    	<= (Eatual == genius_proxima_sequencia) ? 1'b1 : 1'b0;
            contaE    	<= (Eatual == genius_proxima_jogada || Eatual == genius_proxima_mostra) ? 1'b1 : 1'b0;
            pronto    	<= (Eatual == genius_final_acertou || Eatual == genius_final_errou || Eatual == genius_final_timeout) ? 1'b1 : 1'b0;
            acertou   	<= (Eatual == genius_final_acertou) ? 1'b1 : 1'b0;
            errou     	<= (Eatual == genius_final_errou) ? 1'b1 : 1'b0;
            contaT	   	<= (Eatual == genius_espera_jogada) ? 1'b1 : 1'b0;
            zeraM       <= (Eatual == genius_foi_ultima_sequencia || Eatual == preparacao || Eatual == genius_proxima_mostra || Eatual == genius_proxima_sequencia) ? 1'b1 : 1'b0;
            contaM      <= (Eatual == genius_intervalo_rodada || Eatual == genius_mostra_jogada || Eatual == genius_intervalo_mostra) ? 1'b1 : 1'b0;
            fim_timeout <= (Eatual == genius_final_timeout) ? 1'b1 : 1'b0;
            if (Eatual == genius_espera_jogada || Eatual == genius_registra_jogada || Eatual == genius_proxima_jogada 
            || Eatual == genius_compara_jogada || Eatual == genius_foi_ultima_sequencia || Eatual == genius_espera_jogada 
            || Eatual == genius_intervalo_rodada) begin
                seletor <= 2'b10;
            end else if (Eatual == genius_mostra_jogada) begin
                seletor <= 2'b01;
            end else begin
                seletor <= 2'b00;
            end
        end

        if (Minigame == bolo) begin
            // Implementar
        end

        if (Minigame == roupas) begin
            // Implementar
        end
        
        // Assign dos registradores de controle
        if (Eatual == preparacao) begin 
		    Dificuldade <= chaveDificuldade;
			Memoria <= chaveMemoria;
            Minigame <= chaveMinigame;
		end

        // Saida de depuracao (estado)
        db_estado = Eatual;
    end
	
	assign db_dificuldade = Dificuldade;
	assign seletorMemoria = Memoria;

endmodule