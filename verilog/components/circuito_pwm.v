/*
 * circuito_pwm.v - descrição comportamental
 *
 * gera saída com modulacao pwm conforme parametros do modulo
 *
 * parametros: valores definidos para clock de 50MHz (periodo=20ns)
 * ------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     26/09/2021  1.0     Edson Midorikawa  criacao do componente VHDL
 *     17/08/2024  2.0     Edson Midorikawa  componente em Verilog
 *     28/08/2025  2.1     Edson Midorikawa  revisao do componente
 * ------------------------------------------------------------------------
 */
 
module circuito_pwm #(    // valores default
    parameter conf_periodo = 50000, // Periodo do PWM em ciclos de clock (50.000 ciclos => 1 ms)
    parameter largura_000  = 0,     // Largura do pulso p/ 000 [0 ciclos => 0 us]
    parameter largura_001  = 50,    // Largura do pulso p/ 001 [50 ciclos => 1 us]
    parameter largura_010  = 500,   // Largura do pulso p/ 010 [500 ciclos => 10 us]
    parameter largura_011  = 1000,  // Largura do pulso p/ 011 [1000 ciclos => 20 us]
    parameter largura_100  = 1500,  // Largura do pulso p/ 100 [1500 ciclos => 30 us]
    parameter largura_101  = 2000,  // Largura do pulso p/ 101 [2000 ciclos => 40 us]
    parameter largura_110  = 2500,  // Largura do pulso p/ 110 [2500 ciclos => 50 us]
    parameter largura_111  = 3000   // Largura do pulso p/ 111 [3000 ciclos => 60 us]
    
) (
    input        clock,
    input        reset,
    input  [2:0] largura,
    output wire   pwm,
    output wire   db_pwm
);

reg [31:0] contagem; // Contador interno (32 bits) para acomodar conf_periodo
reg [31:0] largura_pwm;


reg s_pwm;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        contagem <= 0;
        s_pwm <= 0;
        largura_pwm <= largura_000; // Valor inicial da largura do pulso
    end else begin
        // Saída PWM
        s_pwm <= (contagem < largura_pwm);

        // Atualização do contador e da largura do pulso
        if (contagem == conf_periodo - 1) begin
            contagem <= 0;
            case (largura)
                3'b000: largura_pwm <= largura_000;
                3'b001: largura_pwm <= largura_001;
                3'b010: largura_pwm <= largura_010;
                3'b011: largura_pwm <= largura_011;
                3'b100: largura_pwm <= largura_100;
                3'b101: largura_pwm <= largura_101;
                3'b110: largura_pwm <= largura_110;
                3'b111: largura_pwm <= largura_111;
                default: largura_pwm <= largura_000; // Valor padrão
            endcase
        end else begin
            contagem <= contagem + 1;
        end
    end
end

assign db_pwm = s_pwm;
assign pwm    = s_pwm;

endmodule
