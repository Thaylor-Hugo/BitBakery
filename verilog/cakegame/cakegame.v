
module cakegame (
    input clock,
    input reset,
    input jogar,
    input dificuldade,
    input [6:0] botoes,
    output [6:0] jogadas,
    output [3:0] estado,
    output [2:0] leds,
    output [6:0] pontuacao,
    output pronto
);
    assign jogadas = 7'b0;
    assign pontuacao = 7'b0;
    assign pronto = 1'b1;
    assign estado = 4'b0;
    assign leds = 3'b0;
    
endmodule
