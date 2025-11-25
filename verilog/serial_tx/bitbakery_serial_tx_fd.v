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
    input [63:0] map_obstacles,
    input conta,
    output saida_serial,
    output fim_tx
);

wire [7:0] s_dados_serial;
wire [3:0] s_sel_pack;

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

mux13x1 mux_serial (
    .D0 (8'hFF),
    .D1 (D0),
    .D2 (D1),
    .D3 (D2),
    .D4 (map_obstacles[7:0]),
    .D5 (map_obstacles[15:8]),
    .D6 (map_obstacles[23:16]),
    .D7 (map_obstacles[31:24]),
    .D8 (map_obstacles[39:32]),
    .D9 (map_obstacles[47:40]),
    .D10 (map_obstacles[55:48]),
    .D11 (map_obstacles[63:56]),
    .D12 (8'hFE),
    .SEL (s_sel_pack),
    .OUT (s_dados_serial)
);

contador_m #(.M(13), .N(4)) contador_serial (
    .clock      (clock),   
    .zera_as    (),
    .zera_s     (reset),
    .conta	    (conta),
    .Q          (s_sel_pack),
    .fim        (),
    .meio       ()
);
endmodule
