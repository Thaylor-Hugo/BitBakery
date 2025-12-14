// ---------------------------------------------------------------------
// BitBakery Serial Transmitter Testbench - 8E1 Format
// ---------------------------------------------------------------------
// Description : Testbench for BitBakery serial transmitter
//               Sends A, B, C, D values four times then stops
// ---------------------------------------------------------------------

`timescale 1ns/1ns

module bitbakery_serial_tx_tb;

// Declaracao de sinais
reg clock;
reg reset;
reg [7:0] D0, D1, D2, D3;
wire saida_serial;

// Contador de pacotes transmitidos
integer packet_count;

// Configuracao do clock
parameter CLOCK_PERIOD = 20; // 50 MHz (20ns period)

// Instanciacao do DUT (Device Under Test)
bitbakery_serial_tx dut (
    .clock         (clock),
    .reset         (reset),
    .D0            (D0),
    .D1            (D1),
    .D2            (D2),
    .D3            (D3),
    .saida_serial  (saida_serial)
);

// Gerador de clock
always #(CLOCK_PERIOD/2) clock = ~clock;

// Configuracao do ambiente de simulacao
initial begin
    $display("Inicio da simulacao");
    $display("Testbench: BitBakery Serial Transmitter 8E1");
    $display("Transmitindo A, B, C, D quatro vezes");
    $display("--------------------------------------------------");
    
    // Condicoes iniciais
    clock = 0;
    reset = 1;
    packet_count = 0;
    
    // Valores a serem transmitidos (A, B, C, D em ASCII)
    D0 = 8'h41; // 'A' = 0x41 = 65
    D1 = 8'h42; // 'B' = 0x42 = 66
    D2 = 8'h43; // 'C' = 0x43 = 67
    D3 = 8'h44; // 'D' = 0x44 = 68
    
    $display("D0 = 0x%h ('%c')", D0, D0);
    $display("D1 = 0x%h ('%c')", D1, D1);
    $display("D2 = 0x%h ('%c')", D2, D2);
    $display("D3 = 0x%h ('%c')", D3, D3);
    $display("--------------------------------------------------");
    
    // Reset
    #(10*CLOCK_PERIOD);
    reset = 0;
    #(10*CLOCK_PERIOD);
    
    // Monitor de transmissao
    // Cada pacote 8E1 tem 11 bits (start + 8 data + parity + stop)
    // Com baud rate de 115200, cada bit dura ~8.68us
    // Com clock de 50MHz e tick de 434 ciclos, cada transmissao leva ~434*11 = 4774 ciclos
    // 4 pacotes = ~19096 ciclos ~= 382us
    
    // Aguardar 4 transmissoes completas (4 pacotes * 4 bytes = 16 bytes)
    // Tempo estimado: 16 bytes * 11 bits/byte * 8.68us/bit = ~1.53ms
    // Em ciclos de clock: ~76500 ciclos @ 50MHz
    
    #(100000*CLOCK_PERIOD); // Aguardar tempo suficiente para 4 transmissoes completas
    
    $display("--------------------------------------------------");
    $display("Fim da simulacao");
    $display("Total de tempo simulado: %0t ns", $time);
    $stop;
end

// Monitor para acompanhar a saida serial
always @(negedge saida_serial) begin
    if (!reset) begin
        $display("[%0t ns] Start bit detectado", $time);
    end
end

// Dump de ondas para visualizacao (GTKWave ou ModelSim)
initial begin
    $dumpfile("bitbakery_serial_tx_tb.vcd");
    $dumpvars(0, bitbakery_serial_tx_tb);
end

endmodule
