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
	input meioL,
    input enderecoIgualLimite,
    input enderecoMenorLimite,
	input chaveDificuldade,
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
	 output reg seletorMemoria,
     output reg reset_random,
	 output  db_dificuldade
);

    // Define estados
    parameter inicial               = 4'b0000;  // 0
    parameter preparacao            = 4'b0001;  // 1
    parameter proxima_mostra        = 4'b0010;  // 2
    parameter espera_jogada         = 4'b0011;  // 3
    parameter registra_jogada       = 4'b0100;  // 4
    parameter compara_jogada        = 4'b0101;  // 5
    parameter proxima_jogada        = 4'b0110;  // 6
    parameter foi_ultima_sequencia  = 4'b0111;  // 7
    parameter proxima_sequencia     = 4'b1000;  // 8
    parameter mostra_jogada         = 4'b1001;  // 9    
    parameter intervalo_mostra      = 4'b1010;  // A
    parameter inicia_sequencia      = 4'b1011;  // B
	parameter intervalo_rodada      = 4'b1100;  // C
    parameter final_timeout 	    = 4'b1101;  // D
    parameter final_acertou         = 4'b1110;  // E
    parameter final_errou           = 4'b1111;  // F
	 

    // Variaveis de estado
    reg [3:0] Eatual, Eprox;
	 reg Dificuldade;

    initial begin
        Eatual = inicial;
		  Dificuldade = 1'b0;
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
            preparacao:       Eprox <= mostra_jogada;
            mostra_jogada:    Eprox <= meioM ? intervalo_mostra : mostra_jogada;
            intervalo_mostra: Eprox <= fimM ? proxima_mostra : intervalo_mostra;
            proxima_mostra:   Eprox <= enderecoIgualLimite ? inicia_sequencia : mostra_jogada;
            inicia_sequencia: Eprox <= espera_jogada;
            espera_jogada:    begin 
                if (jogada) begin
					Eprox <= registra_jogada;
				end else if (timeout) begin
					Eprox <= final_timeout;
				end else begin
					Eprox <= espera_jogada;
				end
            end													
            registra_jogada:  Eprox <= compara_jogada;
            compara_jogada:   begin 
                if (enderecoMenorLimite && botoesIgualMemoria) begin
					Eprox <= proxima_jogada;
				end else if (enderecoIgualLimite && botoesIgualMemoria) begin
					Eprox <= foi_ultima_sequencia ;
				end else begin
					Eprox <= final_errou;
				end
            end													
            proxima_jogada:         Eprox <= espera_jogada;
            foi_ultima_sequencia:   Eprox <= (fimL || (meioL && ~Dificuldade)) ? final_acertou : intervalo_rodada;
			intervalo_rodada:        Eprox <= meioM ? proxima_sequencia : intervalo_rodada;
            proxima_sequencia:      Eprox <= mostra_jogada;
            final_timeout:          Eprox <= iniciar ? preparacao : final_timeout;
            final_errou:            Eprox <= iniciar ? preparacao : final_errou;
            final_acertou:          Eprox <= iniciar ? preparacao : final_acertou;
            default:                Eprox <= inicial;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        zeraL     	<= (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
        zeraR     	<= (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
        zeraE     	<= (Eatual == inicial || Eatual == preparacao || Eatual == proxima_sequencia || Eatual == inicia_sequencia) ? 1'b1 : 1'b0;
        registraR 	<= (Eatual == registra_jogada) ? 1'b1 : 1'b0;
        contaL    	<= (Eatual == proxima_sequencia) ? 1'b1 : 1'b0;
        contaE    	<= (Eatual == proxima_jogada || Eatual == proxima_mostra) ? 1'b1 : 1'b0;
        pronto    	<= (Eatual == final_acertou || Eatual == final_errou || Eatual == final_timeout) ? 1'b1 : 1'b0;
        acertou   	<= (Eatual == final_acertou) ? 1'b1 : 1'b0;
        errou     	<= (Eatual == final_errou) ? 1'b1 : 1'b0;
		contaT	   	<= (Eatual == espera_jogada) ? 1'b1 : 1'b0;
		zeraM       <= (Eatual == foi_ultima_sequencia || Eatual == preparacao || Eatual == proxima_mostra || Eatual == proxima_sequencia) ? 1'b1 : 1'b0;
        contaM      <= (Eatual == intervalo_rodada || Eatual == mostra_jogada || Eatual == intervalo_mostra) ? 1'b1 : 1'b0;
        fim_timeout <= (Eatual == final_timeout) ? 1'b1 : 1'b0;
        reset_random <= (Eatual == final_acertou || Eatual == final_errou || Eatual == final_timeout) ? 1'b1 : 1'b0;
        seletorMemoria <= (Eatual == preparacao) ? 1'b1 : 1'b0;
        if (Eatual == espera_jogada || Eatual == registra_jogada || Eatual == proxima_jogada 
		  || Eatual == compara_jogada || Eatual == foi_ultima_sequencia || Eatual == espera_jogada 
		  || Eatual == intervalo_rodada) begin
            seletor <= 2'b10;
        end else if (Eatual == mostra_jogada) begin
            seletor <= 2'b01;
        end else begin
            seletor <= 2'b00;
        end

        if (Eatual == preparacao) begin 
		    Dificuldade <= chaveDificuldade;
		end

        // Saida de depuracao (estado)
        case (Eatual)
            inicial:                db_estado <= 4'b0000;  // 0
            preparacao:             db_estado <= 4'b0001;  // 1
            proxima_mostra:         db_estado <= 4'b0010;  // 2
            espera_jogada:          db_estado <= 4'b0011;  // 3
            registra_jogada:        db_estado <= 4'b0100;  // 4
            compara_jogada:         db_estado <= 4'b0101;  // 5
            proxima_jogada:         db_estado <= 4'b0110;  // 6
            foi_ultima_sequencia:   db_estado <= 4'b0111;  // 7
            proxima_sequencia:      db_estado <= 4'b1000;  // 8
            mostra_jogada:          db_estado <= 4'b1001;  // 9
            intervalo_mostra:       db_estado <= 4'b1010;  // A
            inicia_sequencia:       db_estado <= 4'b1011;  // B
			   intervalo_rodada:        db_estado <= 4'b1100;  // C
            final_timeout:	 	      db_estado <= 4'b1101;  // D
            final_acertou:          db_estado <= 4'b1110;  // E
            final_errou:            db_estado <= 4'b1111;  // F
            default:                db_estado <= 4'b1001;  // 9 ERRO
        endcase
    end
	
	assign db_dificuldade = Dificuldade;

endmodule