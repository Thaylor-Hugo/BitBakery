// ---------------------------------------------------------------------
// BitBakery Serial Transmitter - 8E1 Format
// ---------------------------------------------------------------------
// Description : Transmitter module for BitBakery game using 8E1 serial format
// Trasnmitter sends 133 packets of data indefinitely
// ---------------------------------------------------------------------

module bitbakery_serial_tx (
    input clock,
    input reset,
    input [7:0] D0,
    input [7:0] D1,
    input [7:0] D2,
    input [511:0] map_obstacles,
    input [511:0] map_objectives,
    output saida_serial
);

wire s_fim_tx, s_iniciar, s_conta;

bitbakery_serial_tx_fd fd (
    .clock          (clock        ),
    .reset          (reset        ),
    .iniciar        (s_iniciar    ),
    .D0             (D0           ),
    .D1             (D1           ),
    .D2             (D2           ),
    .map_obstacles  (map_obstacles),
    .map_objectives (map_objectives),
    .conta          (s_conta      ),
    .saida_serial   (saida_serial ),
    .fim_tx         (s_fim_tx     )
);

bitbakery_serial_tx_uc uc (
    .clock      (clock  ),
    .reset      (reset  ),
    .fim_tx     (s_fim_tx ),
    .conta      (s_conta  ),
    .iniciar    (s_iniciar)
);

endmodule
