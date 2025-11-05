// ---------------------------------------------------------------------
// BitBakery Serial Transmitter - 8E1 Format
// ---------------------------------------------------------------------
// Description : Data Flow module for Transmitter of BitBakery game using 8E1 serial format
// ---------------------------------------------------------------------

module bitbakery_serial_tx_fd (
    input clock,
    input reset,
    input iniciar,
    input [7:0] D0,
    input [7:0] D1,
    input [7:0] D2,
    input [7:0] D3,
    input conta,
    output saida_serial,
    output fim_tx
);

wire [7:0] s_dados_serial;
wire [1:0] s_sel_pack;

tx_serial_8E1 tx_serial (
    .clock           (clock),
    .reset           (reset),
    .partida         (iniciar),
    .dados_ascii     (s_dados_serial), // 8 bits
    .saida_serial    (saida_serial),
    .pronto          (fim_tx),
    .db_clock        ( ),
    .db_tick         ( ),
    .db_partida      ( ),
    .db_saida_serial ( ),
    .db_estado       ( )
);

mux8x1 mux_serial (
    .D0 (D0),
    .D1 (D1),
    .D2 (D2),
    .D3 (D3),
    .SEL (s_sel_pack),
    .OUT (s_dados_serial)
);

contador_m #(.M(4), .N(2)) contador_serial (
    .clock      (clock),   
    .zera_as    (),
    .zera_s     (reset),
    .conta	    (conta),
    .Q          (s_sel_pack),
    .fim        (),
    .meio       ()
);
endmodule
