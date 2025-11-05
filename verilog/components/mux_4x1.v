/*------------------------------------------------------------------------
 * Arquivo   : mux4x1.v
 * Projeto   : Jogo do Desafio da Memoria
 *------------------------------------------------------------------------
 * Descricao : multiplexador 4x1
 *
 * adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL"
 *
 * exemplo de uso: ver testbench mux4x1_tb.v
 *------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     15/02/2024  1.0     Edson Midorikawa  criacao
 *     31/01/2025  1.1     Edson Midorikawa  revisao
 *------------------------------------------------------------------------
 */

module mux4x1 #(
    parameter N = 7
) (
    input [N-1:0] D0,
    input [N-1:0] D1,
    input [N-1:0] D2,
    input [N-1:0] D3,
    input [1:0] SEL,
    output reg [N-1:0] OUT
);

always @(*) begin
    case (SEL)
        2'b00:    OUT = D0;
        2'b01:    OUT = D1;
        2'b10:    OUT = D2;
        2'b11:    OUT = D3;
        default: OUT = {N{1'b0}};
    endcase
end

endmodule
