/*------------------------------------------------------------------------
 * Arquivo   : mux2x1.v
 * Projeto   : Jogo do Desafio da Memoria
 *------------------------------------------------------------------------
 * Descricao : multiplexador 8x1
 * 
 * adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL"
 * 
 * exemplo de uso: ver testbench mux3x1_tb.v
 *------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     15/02/2024  1.0     Edson Midorikawa  criacao
 *     31/01/2025  1.1     Edson Midorikawa  revisao
 *------------------------------------------------------------------------
 */

module mux13x1 (
    input [7:0] D0,
    input [7:0] D1,
    input [7:0] D2,
    input [7:0] D3,
    input [7:0] D4,
    input [7:0] D5,
    input [7:0] D6,
    input [7:0] D7,
    input [7:0] D8,
    input [7:0] D9,
    input [7:0] D10,
    input [7:0] D11,
    input [7:0] D12,
    input [3:0] SEL,
    output reg [7:0] OUT
);

always @(*) begin
    case (SEL)
        4'b0000:    OUT = D0;
        4'b0001:    OUT = D1;
        4'b0010:    OUT = D2;
        4'b0011:    OUT = D3;
        4'b0100:    OUT = D4;
        4'b0101:    OUT = D5;
        4'b0110:    OUT = D6;
        4'b0111:    OUT = D7;
        4'b1000:    OUT = D8;
        4'b1001:    OUT = D9;
        4'b1010:    OUT = D10;
        4'b1011:    OUT = D11;
        4'b1100:    OUT = D12;
        default: OUT = 8'b0; // saida em 0
    endcase
end

endmodule
