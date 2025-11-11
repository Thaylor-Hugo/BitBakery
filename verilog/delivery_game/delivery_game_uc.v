module delivery_game_uc (
    input clock,
    input reset,
    input jogar,
    input game_over,
    output velocity_ready,
    output [3:0] estado,
    output reg reset_out,
    output reg pronto,
    output reg count_map,
    output reg get_velocity
);

parameter IDLE = 4'h0;
parameter PREPARATION = 4'h1;
parameter PLAYING = 4'h2;
parameter GET_VELOCITY = 4'h3;
parameter GAME_OVER = 4'h4;

reg [3:0] Eatual, Eprox;

initial begin
    Eatual <= IDLE;
    Eprox <= IDLE;
end

// Memoria de estado
always @(posedge clock or posedge reset) begin
    if (reset)
        Eatual <= IDLE;
    else
        Eatual <= Eprox;
end

// Logica de proximo estado
always @* begin
    case (Eatual)
        IDLE     : Eprox = (jogar) ? PREPARATION : IDLE;
        PREPARATION : Eprox = PLAYING;
        PLAYING  : Eprox = (game_over) ? GAME_OVER : (velocity_ready) ? GET_VELOCITY : PLAYING;
        GET_VELOCITY : Eprox = PLAYING;
        GAME_OVER: Eprox = (jogar) ? PREPARATION : GAME_OVER;
        default  : Eprox = IDLE;
    endcase
end

// Logica de saida (maquina de Moore)
always @* begin
    reset_out    = (Eatual == IDLE) ? 1'b1 : 1'b0;
    pronto        = (Eatual == GAME_OVER) ? 1'b1 : 1'b0;
    count_map     = (Eatual == PLAYING || Eatual == GET_VELOCITY) ? 1'b1 : 1'b0;
    get_velocity  = (Eatual == PREPARATION || Eatual == GET_VELOCITY) ? 1'b1 : 1'b0;
end

assign estado = Eatual;

endmodule