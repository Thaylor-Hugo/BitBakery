/* --------------------------------------------------------------------------
 *  Arquivo   : mock_hcsr04.v
 * --------------------------------------------------------------------------
 *  Descricao : Mock do sensor ultrassonico HC-SR04 para simulacao
 *              Simula o comportamento real do sensor respondendo ao trigger
 *              com um pulso de echo cuja duracao representa a distancia
 *              
 *              Distancias simuladas (2 bits de entrada):
 *              - 2'b00 :  1cm (   58us de echo)
 *              - 2'b01 :  6cm (  348us de echo)
 *              - 2'b10 : 10cm (  580us de echo)
 *              - 2'b11 : 14cm (  812us de echo)
 *              
 *              Timing do HC-SR04:
 *              - Trigger: pulso de 10us minimo
 *              - Delay ate echo: ~150us (simulado como 150 ciclos de 1us)
 *              - Echo: 58us por cm de distancia
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      10/11/2024  1.0     GitHub Copilot    versao inicial
 * --------------------------------------------------------------------------
 */

module mock_hcsr04 (
    input wire clock,           // Clock de 1MHz (periodo de 1us) para timing correto
    input wire reset,
    input wire trigger,         // Pulso de trigger do controlador
    input wire [1:0] distancia, // Distancia simulada (00=1cm, 01=6cm, 10=10cm, 11=14cm)
    output reg echo             // Pulso de echo para o controlador
);

// Estados da maquina de estados
localparam IDLE         = 3'd0;
localparam WAIT_TRIGGER = 3'd1;
localparam DELAY        = 3'd2;
localparam ECHO_PULSE   = 3'd3;

// Registradores
reg [2:0] estado;
reg [11:0] contador;
reg [11:0] echo_duration;

// Duracao do echo em microsegundos baseada na distancia
// 58us por cm (ida e volta do som)
wire [11:0] duracao_1cm  = 12'd58;   //  1cm
wire [11:0] duracao_6cm  = 12'd348;  //  6cm (58*6)
wire [11:0] duracao_10cm = 12'd580;  // 10cm (58*10)
wire [11:0] duracao_14cm = 12'd812;  // 14cm (58*14)

// Delay antes do echo (tempo de processamento do sensor)
localparam SENSOR_DELAY = 12'd150;   // 150us de delay

// Inicializacao
initial begin
    estado = IDLE;
    echo = 1'b0;
    contador = 12'd0;
    echo_duration = duracao_1cm;
end

// Selecao da duracao do echo baseada na distancia
always @(*) begin
    case (distancia)
        2'b00: echo_duration = duracao_1cm;
        2'b01: echo_duration = duracao_6cm;
        2'b10: echo_duration = duracao_10cm;
        2'b11: echo_duration = duracao_14cm;
        default: echo_duration = duracao_1cm;
    endcase
end

// Maquina de estados
always @(posedge clock or posedge reset) begin
    if (reset) begin
        estado <= IDLE;
        echo <= 1'b0;
        contador <= 12'd0;
    end
    else begin
        case (estado)
            IDLE: begin
                echo <= 1'b0;
                contador <= 12'd0;
                if (trigger) begin
                    estado <= WAIT_TRIGGER;
                end
            end
            
            WAIT_TRIGGER: begin
                // Espera o trigger cair
                if (!trigger) begin
                    estado <= DELAY;
                    contador <= 12'd0;
                end
            end
            
            DELAY: begin
                // Simula o delay do sensor (150us)
                if (contador < SENSOR_DELAY) begin
                    contador <= contador + 1'b1;
                end
                else begin
                    estado <= ECHO_PULSE;
                    contador <= 12'd0;
                    echo <= 1'b1;
                end
            end
            
            ECHO_PULSE: begin
                // Gera o pulso de echo com duracao proporcional a distancia
                if (contador < echo_duration) begin
                    contador <= contador + 1'b1;
                    echo <= 1'b1;
                end
                else begin
                    echo <= 1'b0;
                    estado <= IDLE;
                    contador <= 12'd0;
                end
            end
            
            default: begin
                estado <= IDLE;
                echo <= 1'b0;
                contador <= 12'd0;
            end
        endcase
    end
end

endmodule
