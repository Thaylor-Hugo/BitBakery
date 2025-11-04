// ---------------------------------------------------------------------
// BitBakery Serial Transmitter - 8E1 Format
// ---------------------------------------------------------------------
// Description : Control module for Transmitter of BitBakery game using 8E1 serial format
// ---------------------------------------------------------------------

module bitbakery_serial_tx_uc (
    input clock,
    input reset,
    input fim_tx,
    output reg conta,
    output reg iniciar
);

parameter idle = 2'b00;
parameter start_tx = 2'b01;
parameter wait_tx = 2'b10;
parameter next_tx = 2'b11;

reg [1:0] Eatual, Eprox;

initial begin
    Eatual <= idle;
    Eprox <= idle;
end

// Memoria de estado
always @(posedge clock or posedge reset) begin
    if (reset)
        Eatual <= idle;
    else
        Eatual <= Eprox;
end

// Logica de proximo estado
always @* begin
    case (Eatual)
        idle     : Eprox = start_tx;
        start_tx : Eprox = wait_tx; 
        wait_tx  : Eprox = (fim_tx) ? next_tx : wait_tx;
        next_tx  : Eprox = start_tx;
        default  : Eprox = idle;
    endcase
end

// Logica de saida (maquina de Moore)
always @* begin
    iniciar = (Eatual == start_tx) ? 1'b1 : 1'b0;
    conta   = (Eatual == next_tx) ? 1'b1 : 1'b0;
end

endmodule
