//------------------------------------------------------------------
// Arquivo   : mux_out.v
// Projeto   : Multiplexador de saida
//------------------------------------------------------------------
// Descricao : Multiplexa as saidas dos minigames
//
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/03/2025  1.0     T5BB5             versao inicial
//------------------------------------------------------------------
//

module mux_out (
    input [1:0] minigame,
    input [2:0] leds_0,
    input [3:0] estado_0,
    input [6:0] jogada_0,
    input [6:0] pontuacao_0,
    input pronto_0,
    input [2:0] leds_1,
    input [3:0] estado_1,
    input [6:0] jogada_1,
    input [6:0] pontuacao_1,
    input pronto_1,
    input [2:0] leds_2,
    input [3:0] estado_2,
    input [6:0] jogada_2,
    input [6:0] pontuacao_2,
    input pronto_2,
    input [3:0] estado_inicial,
    output reg [2:0] leds_out,
    output reg [3:0] estado_out,
    output reg [6:0] jogada_out,
    output reg [6:0] pontuacao_out,
    output reg pronto_out
);

always @(*) begin
    case (minigame)
        2'b00: begin
            leds_out = leds_0;
            estado_out = estado_0;
            jogada_out = jogada_0;
            pontuacao_out = pontuacao_0;
            pronto_out = pronto_0;
        end
        2'b01: begin
            leds_out = leds_1;
            estado_out = estado_1;
            jogada_out = jogada_1;
            pontuacao_out = pontuacao_1;
            pronto_out = pronto_1;
        end
        2'b10: begin
            leds_out = leds_2;
            estado_out = estado_2;
            jogada_out = jogada_2;
            pontuacao_out = pontuacao_2;
            pronto_out = pronto_2;
        end
        2'b11: begin
            leds_out = 3'b0;
            jogada_out = 7'b0;
            estado_out = estado_inicial;
            pontuacao_out = 7'b0;
            pronto_out = 1'b0;
        end
        default: begin
            leds_out = 3'b0;
            estado_out = 4'b0;
            jogada_out = 7'b0;
            pontuacao_out = 7'b0;
            pronto_out = 1'b0;
        end
    endcase
end
    
endmodule
