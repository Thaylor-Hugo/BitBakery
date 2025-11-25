module delivery_game_uc (
    input clock,
    input reset,
    input jogar,
    input game_over,
    input velocity_ready,
    input end_delay,
    input velocity_timeout,
    output [3:0] estado,
    output reg reset_out,
    output reg pronto,
    output reg count_map,
    output reg get_velocity,
    output reg reset_delay,
    output reg conta_delay,
    output reg reset_timeout,
    output reg conta_timeout,
    output reg reset_ultrasonico
);

parameter IDLE = 4'h0;
parameter PREPARATION = 4'h1;
parameter GET_VELOCITY = 4'h2;
parameter WAIT_VELOCITY = 4'h3;
parameter DELAY = 4'h4;
parameter GAME_OVER = 4'h5;
parameter RESET_ULTRA = 4'h6;

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
        PREPARATION : Eprox = GET_VELOCITY;
        GET_VELOCITY : Eprox = (game_over) ? GAME_OVER : WAIT_VELOCITY;
        WAIT_VELOCITY : Eprox = (game_over) ? GAME_OVER : (velocity_ready) ? DELAY : (velocity_timeout) ? RESET_ULTRA : WAIT_VELOCITY;
        DELAY : Eprox = (game_over) ? GAME_OVER : (end_delay) ? GET_VELOCITY : DELAY;
        GAME_OVER: Eprox = (jogar) ? PREPARATION : GAME_OVER;
        RESET_ULTRA: Eprox = GET_VELOCITY;
        default  : Eprox = IDLE;
    endcase
end

// Logica de saida (maquina de Moore)
always @* begin
    reset_out    = (Eatual == IDLE || Eatual == PREPARATION) ? 1'b1 : 1'b0;
    pronto        = (Eatual == GAME_OVER) ? 1'b1 : 1'b0;
    count_map     = (Eatual == GET_VELOCITY || Eatual == WAIT_VELOCITY || Eatual == DELAY) ? 1'b1 : 1'b0;
    get_velocity  = (Eatual == GET_VELOCITY) ? 1'b1 : 1'b0;
    reset_delay   = (Eatual == GET_VELOCITY || Eatual == PREPARATION) ? 1'b1 : 1'b0;
    conta_delay   = (Eatual == DELAY) ? 1'b1 : 1'b0;
    reset_timeout = (Eatual == GET_VELOCITY) ? 1'b1 : 1'b0;
    conta_timeout = (Eatual == WAIT_VELOCITY) ? 1'b1 : 1'b0;
    reset_ultrasonico = (Eatual == RESET_ULTRA || Eatual == PREPARATION) ? 1'b1 : 1'b0;
end

assign estado = Eatual;

endmodule