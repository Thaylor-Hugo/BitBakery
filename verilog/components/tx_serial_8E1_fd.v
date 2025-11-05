/* -------------------------------------------------------------
 * Arquivo   : tx_serial_8E1_fd.v
 *--------------------------------------------------------------
 * Descricao : fluxo de dados do circuito base de transmissao 
 *             serial assincrona (8E1) 
 *             ==> contem deslocador com 11 bits e contador
 *                 modulo 12
 * 
 *--------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     30/08/2025  1.0     Edson Midorikawa  criacao
 *     03/11/2025  2.0     Thaylor Hugo      conversao para 8E1
 *     04/11/2025  2.1     Thaylor Hugo      correcao bit ordering
 *--------------------------------------------------------------
 */
 
 module tx_serial_8E1_fd (
    input        clock        ,
    input        reset        ,
    input        zera         ,
    input        conta        ,
    input        carrega      ,
    input        desloca      ,
    input  [7:0] dados_ascii  ,
    output       saida_serial ,
    output       fim
);

    wire [11:0] s_dados;
    wire [11:0] s_saida;
    wire s_paridade;

    // Calculo da paridade
    xor_paridade xor_paridade (
        .dados    (dados_ascii),
        .paridade (s_paridade)
    );

    // composicao dos dados seriais (8E1)
    // Formato: [idle][start][D0][D1][D2][D3][D4][D5][D6][D7][parity][stop]
    assign s_dados[0]   = 1'b1;             // idle state
    assign s_dados[1]   = 1'b0;             // start bit
    assign s_dados[2]   = dados_ascii[0];   // bit 0 (LSB)
    assign s_dados[3]   = dados_ascii[1];   // bit 1
    assign s_dados[4]   = dados_ascii[2];   // bit 2
    assign s_dados[5]   = dados_ascii[3];   // bit 3
    assign s_dados[6]   = dados_ascii[4];   // bit 4
    assign s_dados[7]   = dados_ascii[5];   // bit 5
    assign s_dados[8]   = dados_ascii[6];   // bit 6
    assign s_dados[9]   = dados_ascii[7];   // bit 7 (MSB)
    assign s_dados[10]  = s_paridade;       // even parity bit
    assign s_dados[11]  = 1'b1;             // stop bit
  
    // Instanciação do deslocador_n
    deslocador_n #(
        .N(12) 
    ) U1 (
        .clock         (clock  ),
        .reset         (reset  ),
        .carrega       (carrega),
        .desloca       (desloca),
        .entrada_serial(1'b1   ), // stop bit comes from shift register fill
        .dados         (s_dados),
        .saida         (s_saida)
    );
    
    // Instanciação do contador_m
    contador_m #(
        .M(12),
        .N(4)
    ) U2 (
        .clock   (clock),
        .zera_as (1'b0 ),
        .zera_s  (zera ),
        .conta   (conta),
        .Q       (     ), // porta Q em aberto (desconectada)
        .fim     (fim  ),
        .meio    (     )  // porta meio em aberto (desconectada)
    );
    
    // Saida serial do transmissor
    assign saida_serial = s_saida[0];
  
endmodule
