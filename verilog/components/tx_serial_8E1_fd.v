/* -------------------------------------------------------------
 * Arquivo   : tx_serial_8E1_fd.v
 *--------------------------------------------------------------
 * Descricao : fluxo de dados do circuito base de transmissao 
 *             serial assincrona (8E1) 
 *             ==> contem deslocador com 11 bits e contador
 *                 modulo 11
 * 
 *--------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     30/08/2025  1.0     Edson Midorikawa  criacao
 *     03/11/2025  2.0     Thaylor Hugo      conversao para 8E1
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

    wire [10:0] s_dados;
    wire [10:0] s_saida;

    // composicao dos dados seriais (8E1)
    assign s_dados[0]   = 1'b1;             // repouso
    assign s_dados[1]   = 1'b0;             // start bit
    assign s_dados[9:2] = dados_ascii[7:0]; // 8 bits de dado
    // s_dados[10] = paridade (atribuido pelo xor_paridade)
  
    // Instanciação do deslocador_n
    deslocador_n #(
        .N(11) 
    ) U1 (
        .clock         (clock  ),
        .reset         (reset  ),
        .carrega       (carrega),
        .desloca       (desloca),
        .entrada_serial(1'b1   ), 
        .dados         (s_dados),
        .saida         (s_saida)
    );

    xor_paridade xor_paridade (
        .dados    (dados_ascii),
        .paridade (s_dados[10]) // bit de paridade even (posição 10)
    );
    
    // Instanciação do contador_m
    contador_m #(
        .M(11),
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
