//------------------------------------------------------------------
// Arquivo   : bitbakery.v
// Projeto   : BitBakery
//------------------------------------------------------------------
// Descricao : BitBakery Top Module
//
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/03/2025  1.0     T5BB5             versao inicial
//------------------------------------------------------------------
//

module bitbakery (
    input clock_in,
    input reset_in,
    input iniciar_in,
    input dificuldade,
    input [1:0] minigame,
    input [6:0] botoes_in,
    input echo,
    output saida_serial,
    output pwm,
    output trigger,
    output [2:0] pontuacao_out,
    output [6:0] db_estado,
    output [1:0] db_minigame,
    output [6:0] db_jogada,
    output db_iniciar,
	output db_clock,
    output [3:0] db_player_position,
    output [63:0] db_map_objective,
    output [63:0] db_map_obstacle
);

parameter inicial = 3'b000;
parameter preparacao = 3'b001;
parameter execucao = 3'b010;
parameter fim = 3'b011;
parameter intervalo = 3'b100;
parameter start_game = 3'b101;

wire reset, iniciar, clock;
wire [6:0] botoes;
assign iniciar = ~iniciar_in;
assign reset = ~reset_in;
assign botoes = ~botoes_in;

wire s_pronto_0, s_pronto_1, s_pronto_2, s_pronto, fim_intervalo;
wire [3:0] s_estado_0, s_estado_1, s_estado_2, s_estado_inicial, s_estado;
wire [6:0] s_jogada_0, s_jogada_1, s_jogada_2;
wire [2:0] s_pontuacao_0, s_pontuacao_1, s_pontuacao_2;
wire [3:0] estado_out;
wire [3:0] s_player_position;
wire [63:0] s_map_objective, s_map_obstacle;

reg [1:0] MiniGame; 
reg [2:0] Eatual, Eprox;
reg Dificuldade, s_iniciar;

assign db_clock = clock;
assign db_minigame = MiniGame;
assign db_iniciar = iniciar;
assign estado_out = (Eatual == intervalo)? 4'b0001 : s_estado;
assign db_dificuldade = Dificuldade;

assign db_map_objective = s_map_objective;
assign db_map_obstacle = s_map_obstacle;
assign db_player_position = s_player_position;


hexa7seg display_state (
	.hexa (estado_out),
	.display (db_estado)
);


initial begin
    MiniGame <= 2'b11;
    Dificuldade <= 1'b0;
    Eatual <= 2'b00;
    Eprox <= 2'b00;
end

always @(posedge clock or posedge reset) begin
    if (reset)
        Eatual <= inicial;
    else
        Eatual <= Eprox;
end

// Máquina de estados
always @* begin
    case (Eatual)
        inicial: Eprox = iniciar ? preparacao : inicial;
        preparacao: Eprox = (MiniGame != 2'b11)? intervalo : preparacao;
        intervalo: Eprox = fim_intervalo ? start_game : intervalo;
        start_game: Eprox = execucao;
        execucao: Eprox = s_pronto ? fim : execucao;
        fim: Eprox = iniciar ? preparacao : fim; 
        default: Eprox = inicial;
    endcase
end


contador_m  #(.M(2000), .N(32)) contador_intervalo (
    .clock      (clock),   
    .zera_as    (Eatual == iniciar),
    .zera_s     (1'b0),
    .conta	    (Eatual == intervalo),
    .Q          (),
    .fim        (fim_intervalo),
    .meio       ()
);

// Lógica de saída
always @* begin
    s_iniciar <= (Eatual == start_game)? 1'b1 : 1'b0;
    Dificuldade <= (Eatual == preparacao || Eatual == inicial)? dificuldade : Dificuldade;
    MiniGame <= (Eatual == preparacao || Eatual == inicial)? minigame : MiniGame;
end

assign pontuacao_out = {Dificuldade, 1'b0, 1'b0};

clock_diviser clock_out (
    .clock (clock_in),
    .clock_divised (clock)
);

mux_out saidas (
    .minigame       (MiniGame),
    .estado_0       (s_estado_0),
    .jogada_0       (s_jogada_0),
    .pronto_0       (s_pronto_0),
    .pontuacao_0    (s_pontuacao_0),
    .estado_1       (s_estado_1),
    .jogada_1       (s_jogada_1),
    .pronto_1       (s_pronto_1),
    .pontuacao_1    (s_pontuacao_1),
    .estado_2       (s_estado_2),
    .jogada_2       (s_jogada_2),
    .pronto_2       (s_pronto_2),
    .pontuacao_2    (s_pontuacao_2),
    .estado_inicial (s_estado_inicial),
    .estado_out     (s_estado),
    .jogada_out     (db_jogada),
    .pronto_out     (s_pronto),
    .pontuacao_out  ()
);

jogo_desafio_memoria game0 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (~Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_0),
    .jogadas        (s_jogada_0),
    .pontuacao      (s_pontuacao_0),
    .pronto         (s_pronto_0)
);

cakegame game1 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_1),
    .jogadas        (s_jogada_1),
    .pontuacao      (s_pontuacao_1),
    .pronto         (s_pronto_1)
);

delivery_game game3 (
    .clock (clock),
    .reset (reset),
    .jogar (s_iniciar),
    .botoes (botoes),
    .echo (echo),
    .estado (s_estado_2),
    .pontuacao (s_pontuacao_2),
    .pronto (s_pronto_2),
    .pwm (pwm),
    .trigger (trigger),
    .db_player_position (s_player_position),
    .db_map_obstacle (s_map_obstacle),
    .db_map_objective (s_map_objective)
);

bitbakery_serial_tx serial_tx (
    .clock          (clock_in     ),  // Use 50MHz clock directly, not divided clock!
    .reset          (reset        ),
    .D0             ({2'b00, MiniGame, estado_out}),
    .D1             ({2'b01, db_jogada[5:0]}),
    .D2             ({2'b10, db_jogada[6], db_dificuldade, 4'b0000}),
    .D3             (8'b11000000),
    .saida_serial   (saida_serial )
);

assign s_estado_inicial = Eatual;

endmodule

module cakegame_fd (
    input clock,
    input [6:0] buttons,
    input [1:0] out_sel,
    input dificuldade,
    input clear_reg,
    input enable_reg,
    input clear_mem_counter,
    input enable_mem_counter,
    input clear_show_counter,
    input enable_show_counter,
    input enable_timeout_counter,
    input clear_points_counter,
    input enable_points_counter,
    input clear_ram,
    input enable_ram,
    input reset_random,
    output end_mem_counter,
    output correct_play,
    output has_play,
    output end_show,
    output half_show,
    output timeout,
    output [6:0] play,
    output [2:0] points
);

wire [3:0] s_address;
wire [6:0] s_data, s_data_2, s_mem_out, s_ram_out;
wire [6:0] s_reg;
wire signal = buttons[0] | buttons[1] | buttons[2] | buttons[3] | buttons[4] | buttons[5] | buttons[6];
wire [2:0] s_random_address_1;
wire [1:0] s_random_address_2;

// Define saída das Memórias
contador_163 address_counter (
    .clock  (clock),
    .clr    (~clear_mem_counter),
    .ld     (1'b1),
    .ent    (1'b1),
    .enp    (enable_mem_counter),
    .D      (4'b0),
    .Q      (s_address),
    .rco    (end_mem_counter)
);

sync_ram ram (
    .clock          (clock),
    .reset          (clear_ram),
    .write_enable   (enable_ram),
    .address        (s_address),
    .data_in        (s_mem_out),
    .data_out       (s_ram_out)
);

random #(.N(3)) random_address_1 (
    .clock          (clock),
    .reset          (reset_random),
    .write_enable   (1'b1),
    .address        (s_random_address_1)
);

random #(.N(2)) random_address_2 (
    .clock          (clock),
    .reset          (reset_random),
    .write_enable   (1'b1),
    .address        (s_random_address_2)
);

rom rom_1 (
    .clock      (clock),
    .address    (s_random_address_1),
    .data_out   (s_data)
);

rom_easy rom_2 (
    .clock      (clock),
    .address    (s_random_address_2),
    .data_out   (s_data_2)
);

mux2x1 mux_memorias (
    .SEL    (dificuldade),
    .D0     (s_data),
    .D1     (s_data_2),
    .OUT    (s_mem_out)
);

// Detecta Jogada
edge_detector play_detector (
    .clock  (clock),
    .reset  (clear_reg),
    .sinal  (signal),
    .pulso  (has_play)
);

registrador_4 play_reg (
    .clock  (clock),
    .clear  (clear_reg),
    .enable (enable_reg),
    .D      (buttons),
    .Q      (s_reg)
);

// Compara jogada com memórias
comparador compare (
    .A    (s_ram_out),
    .B    (s_reg),
    .ALBo (    ),
    .AGBo (    ),
    .AEBo (correct_play)
);

// General Timers
contador_m  #(.M(1000),.N(32)) show_counter (
    .clock      (clock),   
    .zera_as    (clear_show_counter),
    .zera_s     (1'b0),
    .conta	    (enable_show_counter),
    .Q          (),
    .fim        (end_show),
    .meio       (half_show)
);

contador_m  #(.M(10000), .N(32)) timeout_counter (
    .clock      (clock),   
    .zera_as    (~enable_timeout_counter),
    .zera_s     (1'b0),
    .conta	    (enable_timeout_counter),
    .Q          (),
    .fim        (timeout),
    .meio       ()
);

contador_m #(.M(8), .N(3)) points_counter (
    .clock      (clock),
    .zera_as    (clear_points_counter),
    .zera_s     (1'b0),
    .conta      (enable_points_counter),
    .Q          (points),
    .fim        (),
    .meio       ()
);

// Play output
mux3x1 out_mux (
    .D0     (7'b0),
    .D1     (s_ram_out),
    .D2     (buttons),
    .SEL    (out_sel),
    .OUT    (play)
);

endmodule
module cakegame_uc (
    input clock,
    input reset,
    input start,
    input end_mem_counter,
    input correct_play,
    input has_play,
    input end_show,
    input half_show,
    input timeout,
    output reg [1:0] out_sel,
    output reg clear_reg,
    output reg enable_reg,
    output reg clear_mem_counter,
    output reg enable_mem_counter,
    output reg clear_show_counter,
    output reg enable_show_counter,
    output reg enable_timeout_counter,
    output reg clear_points_counter,
    output reg enable_points_counter,
    output reg clear_ram,
    output reg enable_ram,
    output reg reset_random,
    output reg finished,
    output reg [3:0] state
);
    
// State definitions
parameter inicio        = 4'b0000; // 0
parameter preparation   = 4'b0001; // 1
parameter show_play     = 4'b0010; // 2
parameter show_interval = 4'b0011; // 3
parameter next_show     = 4'b0100; // 4
parameter initiate_play = 4'b0101; // 5
parameter wait_play     = 4'b0110; // 6
parameter register_play = 4'b0111; // 7
parameter compare_play  = 4'b1000; // 8
parameter next_play     = 4'b1001; // 9
parameter start_show    = 4'b1010; // A
parameter register_show = 4'b1011; // B
parameter end_state     = 4'b1100; // C

// State variables
reg [3:0] current_state, next_state;

// Initial state
initial begin
    current_state <= inicio;
end

// State memory
always @(posedge clock or posedge reset) begin
    if (reset)
        current_state <= inicio;
    else
        current_state <= next_state;
end

// Next state logic
always @* begin
    case (current_state)
        inicio:         next_state <= start ? preparation : inicio;
        preparation:    next_state <= half_show ?  start_show : preparation;     // Intervalo para começar - definido para a interface não pular a primeira jogada
        start_show:     next_state <= show_play;
        show_play:      next_state <= half_show ? show_interval : show_play;
        show_interval:  next_state <= end_show ? next_show : show_interval;
        next_show:      next_state <= end_mem_counter ? initiate_play : register_show;
        register_show:  next_state <= show_play;
        initiate_play:  next_state <= wait_play;
        wait_play:      next_state <= has_play ? register_play : timeout ? end_state : wait_play;
        register_play:  next_state <= compare_play;
        compare_play:   next_state <= next_play;
        next_play:      next_state <= end_mem_counter ? end_state : wait_play;
        end_state:      next_state <= start? preparation : end_state;   
        default:        next_state <= inicio;
    endcase
end

// Output logic
always @* begin
    clear_reg <= (current_state == preparation) ? 1'b1 : 1'b0;
    enable_reg <= (current_state == register_play) ? 1'b1 : 1'b0;
    clear_mem_counter <= (current_state == preparation || current_state == initiate_play) ? 1'b1 : 1'b0;
    enable_mem_counter <= (current_state == next_show || current_state == next_play) ? 1'b1 : 1'b0;
    clear_show_counter <= (current_state == start_show || current_state == inicio || current_state == end_state) ? 1'b1 : 1'b0;
    enable_show_counter <= (current_state == preparation || current_state == show_interval || current_state == show_play) ? 1'b1 : 1'b0;
    enable_timeout_counter <= (current_state == wait_play) ? 1'b1 : 1'b0;
    clear_points_counter <= (current_state == preparation) ? 1'b1 : 1'b0;
    enable_points_counter <= (correct_play && (current_state == next_play)) ? 1'b1 : 1'b0;
    clear_ram <= (current_state == preparation) ? 1'b1 : 1'b0;
    enable_ram <= (current_state == start_show || current_state == register_show) ? 1'b1 : 1'b0;
    reset_random <= (current_state == preparation) ? 1'b1 : 1'b0;
    finished <= (current_state == end_state) ? 1'b1 : 1'b0;
    state <= current_state;

    if (current_state == wait_play || current_state == register_play
        || current_state == compare_play || current_state == next_play || current_state == end_state)
        out_sel <= 2'b10;
    else if (current_state == show_play)
        out_sel <= 2'b01;
    else
        out_sel <= 2'b00;
end

endmodule
module cakegame (
    input clock,
    input reset,
    input jogar,
    input dificuldade,
    input [6:0] botoes,
    output [6:0] jogadas,
    output [3:0] estado,
    output [2:0] pontuacao,
    output pronto
);

wire [1:0] s_out_sel;
wire [3:0] s_estado;
wire s_clear_reg, s_enable_reg, s_clear_mem_counter, s_enable_mem_counter, s_clear_show_counter, s_enable_show_counter, s_enable_timeout_counter, s_clear_points_counter, s_enable_points_counter, s_end_mem_counter, s_correct_play, s_has_play, s_end_show, s_half_show, s_timeout, s_pronto;
wire clear_ram, enable_ram, s_reset_random;

cakegame_fd data_flux(
    .clock                  (clock),
    .buttons                (botoes),
    .out_sel                (s_out_sel),
    .dificuldade            (dificuldade),
    .clear_reg              (s_clear_reg),
    .enable_reg             (s_enable_reg),
    .clear_mem_counter      (s_clear_mem_counter),
    .enable_mem_counter     (s_enable_mem_counter),
    .clear_show_counter     (s_clear_show_counter),
    .enable_show_counter    (s_enable_show_counter),
    .enable_timeout_counter (s_enable_timeout_counter),
    .clear_points_counter   (s_clear_points_counter),
    .enable_points_counter  (s_enable_points_counter),
    .clear_ram              (clear_ram),
    .enable_ram             (enable_ram),
    .reset_random           (s_reset_random),
    .end_mem_counter        (s_end_mem_counter),
    .correct_play           (s_correct_play),
    .has_play               (s_has_play),
    .end_show               (s_end_show),
    .half_show              (s_half_show),
    .timeout                (s_timeout),
    .play                   (jogadas),
    .points                 (pontuacao)
);

cakegame_uc control_unit(
    .clock                  (clock),
    .reset                  (reset),
    .start                  (jogar),
    .end_mem_counter        (s_end_mem_counter),
    .correct_play           (s_correct_play),
    .has_play               (s_has_play),
    .end_show               (s_end_show),
    .half_show              (s_half_show),
    .timeout                (s_timeout),
    .out_sel                (s_out_sel),
    .clear_reg              (s_clear_reg),
    .enable_reg             (s_enable_reg),
    .clear_mem_counter      (s_clear_mem_counter),
    .enable_mem_counter     (s_enable_mem_counter),
    .clear_show_counter     (s_clear_show_counter),
    .enable_show_counter    (s_enable_show_counter),
    .enable_timeout_counter (s_enable_timeout_counter),
    .clear_points_counter   (s_clear_points_counter),
    .enable_points_counter  (s_enable_points_counter),
    .clear_ram              (clear_ram),
    .enable_ram             (enable_ram),
    .reset_random           (s_reset_random),
    .finished               (pronto),
    .state                  (s_estado)
);

assign estado = s_estado;

endmodule
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

module clock_diviser(
    input clock,                // Clock de entrada 50MHz
    output reg clock_divised    // Clock de saída 1kHz
);

reg [24:0] counter;

initial begin
    counter <= 0;
    clock_divised <= 0;
end

always @(posedge clock) begin
    if (counter == 25000) begin
        counter <= 0;
        clock_divised <= ~clock_divised;
    end else begin
        counter <= counter + 1;
    end
end
    
endmodule
/* -----------------------------------------------------------------
 *  Arquivo   : comparador_85.v
 *  Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
 * -----------------------------------------------------------------
 * Descricao : comparador de magnitude de 4 bits 
 *             similar ao CI 7485
 *             baseado em descricao comportamental disponivel em	
 * https://web.eecs.umich.edu/~jhayes/iscas.restore/74L85b.v
 * -----------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     21/12/2023  1.0     Edson Midorikawa  criacao
 * -----------------------------------------------------------------
 */

module comparador_85 (ALBi, AGBi, AEBi, A, B, ALBo, AGBo, AEBo);

    input[3:0] A, B;
    input      ALBi, AGBi, AEBi;
    output     ALBo, AGBo, AEBo;
    wire[4:0]  CSL, CSG;

    assign CSL  = ~A + B + ALBi;
    assign ALBo = ~CSL[4];
    assign CSG  = A + ~B + AGBi;
    assign AGBo = ~CSG[4];
    assign AEBo = ((A == B) && AEBi);

endmodule /* comparador_85 */
module comparador (
    input [6:0] A,
    input [6:0] B,
    output ALBo,
    output AGBo,
    output AEBo
);

assign ALBo = (A < B);
assign AGBo = (A > B);
assign AEBo = (A == B);

endmodule//------------------------------------------------------------------
// Arquivo   : contador_163.v
// Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
//------------------------------------------------------------------
// Descricao : Contador binario de 4 bits, modulo 16
//             similar ao componente 74163
//
// baseado no componente Vrcntr4u.v do livro Digital Design Principles 
// and Practices, Fifth Edition, by John F. Wakerly              
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//
module contador_163 ( clock, clr, ld, ent, enp, D, Q, rco );
    input clock, clr, ld, ent, enp;
    input [3:0] D;
    output reg [3:0] Q;
    output reg rco;

    always @ (posedge clock)
        if (~clr)               Q <= 4'd0;
        else if (~ld)           Q <= D;
        else if (ent && enp)    Q <= Q + 1'b1;
        else                    Q <= Q;
 
    always @ (Q or ent)
        if (ent && (Q == 4'd15))   rco = 1;
        else                       rco = 0;
endmodule/* --------------------------------------------------------------------------
 *  Arquivo   : contador_bcd_3digitos.v
 * --------------------------------------------------------------------------
 *  Descricao : componente Verilog de um contador BCD de 3 digitos (contagem
 *              de 000 a 999) com descricao comportamental
 *
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */
 
module contador_bcd_3digitos (
    input  wire      clock,
    input  wire      zera,
    input  wire      conta,
    output  [3:0] digito0,
    output  [3:0] digito1,
    output  [3:0] digito2,
    output        fim
);

    reg [3:0] s_dig2, s_dig1, s_dig0;

    always @(posedge clock) begin
        if (zera) begin 
            s_dig0 <= 4'b0000;
            s_dig1 <= 4'b0000;
            s_dig2 <= 4'b0000;
        end else if (conta) begin
            if (s_dig0 == 4'b1001) begin
                s_dig0 <= 4'b0000;
                if (s_dig1 == 4'b1001) begin
                    s_dig1 <= 4'b0000;
                    if (s_dig2 == 4'b1001) begin
                        s_dig2 <= 4'b0000;
                    end else begin
                        s_dig2 <= s_dig2 + 1'b1; 
                    end
                end else begin
                    s_dig1 <= s_dig1 + 1'b1; 
                end
            end else begin
                s_dig0 <= s_dig0 + 1'b1; 
            end
        end
    end

    // fim de contagem
    assign fim = (s_dig2 == 4'b1001 && s_dig1 == 4'b1001 && s_dig0 == 4'b1001) ? 1'b1 : 1'b0; 

    // saídas
    assign digito2 = s_dig2;
    assign digito1 = s_dig1;
    assign digito0 = s_dig0;

endmodule
/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm_fd
 * --------------------------------------------------------------------------
 *  Descricao : fluxo de dados do componente de contagem de cm 
 *
 *              componente parametrizado em funcao de clocks/cm
 *            
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */

module contador_cm_fd #(
    parameter R = 10,  // razão de clocks por cm
    parameter N = 4    // teto(log2(R)) 
) (
    input wire        clock,
    input wire        pulso,
    input wire        zera_tick,
    input wire        conta_tick,
    input wire        zera_bcd,
    input wire        conta_bcd,
    output wire       tick,
    output wire [3:0] digito0,
    output wire [3:0] digito1,
    output wire [3:0] digito2,
    output wire       fim
);

    // Gera tick do contador de cm a cada ciclo de R
    contador_m #(
        .M (R), 
        .N (N)
    ) U1 (
        .clock   (clock     ),
        .zera_as (1'b0      ),
        .zera_s  (zera_tick ),
        .conta   (conta_tick),
        .Q       (          ),  // s_resto (desconectado)
        .fim     (          ),  // fim (desconectado)
        .meio    (tick      )
    );

    // Contador de distância em cm
    contador_bcd_3digitos U2 (
        .clock   (clock    ),
        .zera    (zera_bcd ),
        .conta   (conta_bcd),
        .digito0 (digito0  ),
        .digito1 (digito1  ),
        .digito2 (digito2  ),
        .fim     (fim      )
    );

endmodule/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm_uc.v
 * --------------------------------------------------------------------------
 *  Descricao : unidade de controle do componente contador_cm
 *              
 *              incrementa contagem de cm a cada sinal de tick enquanto
 *              o pulso de entrada permanece ativo
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 *      12/09/2025  1.0     T2BB5             versao em Verilog
 * --------------------------------------------------------------------------
 */

module contador_cm_uc (
    input wire clock,
    input wire reset,
    input wire pulso,
    input wire tick,
    output reg zera_tick,
    output reg conta_tick,
    output reg zera_bcd,
    output reg conta_bcd,
    output reg pronto
);

    // Tipos e sinais
    reg [2:0] Eatual, Eprox; // 3 bits são suficientes para os estados

    // Parâmetros para os estados
    parameter inicial = 3'b000;
    parameter preparacao = 3'b001;
    parameter espera_tick = 3'b010;
    parameter conta_cm = 3'b011;
    parameter fim_cm = 3'b100;

    // Memória de estado
    always @(posedge clock, posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial: Eprox <= preparacao;
            preparacao: Eprox <= (pulso) ? espera_tick : preparacao;
            espera_tick: Eprox <= (tick) ? conta_cm : (!pulso)? fim_cm : espera_tick;
            conta_cm: Eprox <= espera_tick;
            fim_cm: Eprox <= (pulso) ? preparacao : fim_cm;
        endcase
    end

    // Lógica de saída (Moore)
    always @(*) begin
            zera_tick <= (Eatual == preparacao)? 1'b1: 1'b0;
            conta_tick <= (Eatual == espera_tick || Eatual == conta_cm)? 1'b1: 1'b0;
            zera_bcd <= (Eatual == preparacao)? 1'b1: 1'b0;
            conta_bcd <= (Eatual == conta_cm)? 1'b1: 1'b0;
            pronto <= (Eatual == fim_cm)? 1'b1: 1'b0;
    end

endmodule/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm.v
 * --------------------------------------------------------------------------
 *  Descricao : componente de contagem de cm 
 *
 *              componente parametrizado em funcao de clocks/cm
 *            
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */
 
module contador_cm #(
    parameter R = 10,  // razão de clocks por cm
    parameter N = 4    // teto(log2(R))
) (
    input wire        clock,
    input wire        reset,
    input wire        pulso,
    output wire [3:0] digito0,
    output wire [3:0] digito1,
    output wire [3:0] digito2,
    output wire       fim,
    output wire       pronto
);

    // Sinais internos
    wire s_zera_tick;
    wire s_conta_tick;
    wire s_zera_bcd;
    wire s_conta_bcd;
    wire s_tick;

    // Instanciação do contador_cm_fd
    contador_cm_fd #(
        .R(R), 
        .N(N)
    ) FD (
        .clock     (clock       ),
        .pulso     (pulso       ),
        .zera_tick (s_zera_tick ),
        .conta_tick(s_conta_tick),
        .zera_bcd  (s_zera_bcd  ),
        .conta_bcd (s_conta_bcd ),
        .tick      (s_tick      ),
        .digito0   (digito0     ),
        .digito1   (digito1     ),
        .digito2   (digito2     ),
        .fim       (fim         )
    );

    // Instanciação do contador_cm_uc
    contador_cm_uc UC (
        .clock     (clock       ),
        .reset     (reset       ),
        .pulso     (pulso       ),
        .tick      (s_tick      ),
        .zera_tick (s_zera_tick ),
        .conta_tick(s_conta_tick),
        .zera_bcd  (s_zera_bcd  ),
        .conta_bcd (s_conta_bcd ),
        .pronto    (pronto      )
    );

endmodule
/*---------------Laboratorio Digital-------------------------------------
 * Arquivo   : contador_m.v
 * Projeto   : Experiencia 4 - Desenvolvimento de Projeto de 
 *                             Circuitos Digitais em FPGA
 *-----------------------------------------------------------------------
 * Descricao : contador binario, modulo m, com parametros 
 *             M (modulo do contador) e N (numero de bits),
 *             sinais para clear assincrono (zera_as) e sincrono (zera_s)
 *             e saidas de fim e meio de contagem
 *             
 *-----------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     30/01/2024  1.0     Edson Midorikawa  criacao
 *     16/01/2025  1.1     Edson Midorikawa  revisao
 *-----------------------------------------------------------------------
 */

module contador_m #(parameter M=100, N=7)
  (
   input  wire          clock,
   input  wire          zera_as,
   input  wire          zera_s,
   input  wire          conta,
   output reg  [N-1:0]  Q,
   output reg           fim,
   output reg           meio
  );

  always @(posedge clock or posedge zera_as) begin
    if (zera_as) begin
      Q <= 0;
    end else if (clock) begin
      if (zera_s) begin
        Q <= 0;
      end else if (conta) begin
        if (Q == M-1) begin
          Q <= 0;
        end else begin
          Q <= Q + 1'b1;
        end
      end
    end
  end

  // Saidas
  always @ (Q)
      if (Q == M-1)   fim = 1;
      else            fim = 0;

  always @ (Q)
      if (Q == M/2-1) meio = 1;
      else            meio = 0;

endmodule
/* ------------------------------------------------------------------
 * Arquivo   : deslocador_n.vhd
 * ------------------------------------------------------------------
 * Descricao : deslocador  
 *             > parametro N: numero de bits
 *
 * ------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     09/09/2021  1.0     Edson Midorikawa  versao inicial em VHDL
 *     27/08/2024  3.0     Edson Midorikawa  conversão para Verilog
 * ------------------------------------------------------------------
 */
 
module deslocador_n #(
    parameter N = 4
) (
    input wire         clock,
    input wire         reset,
    input wire         carrega,
    input wire         desloca,
    input wire         entrada_serial,
    input wire [N-1:0] dados,
    output     [N-1:0] saida
);

    reg [N-1:0] IQ;

    always @(posedge clock, posedge reset) begin
        if (reset) begin
            IQ <= {N{1'b1}}; // Inicializa com todos os bits em '1'
        end else begin
            if (carrega) begin
                IQ <= dados;
            end else if (desloca) begin
                IQ <= {entrada_serial, IQ[N-1:1]}; // Deslocamento à direita
            end else begin
                IQ <= IQ;    // Mantém o valor atual
            end
        end
    end

    assign saida = IQ;

endmodule/* ------------------------------------------------------------------------
 *  Arquivo   : edge_detector.v
 *  Projeto   : Experiencia 4 - Desenvolvimento de Projeto de
 *                              Circuitos Digitais com FPGA
 * ------------------------------------------------------------------------
 *  Descricao : detector de borda
 *              gera um pulso na saida de 1 periodo de clock
 *              a partir da detecao da borda de subida sa entrada
 * 
 *              sinal de reset ativo em alto
 * 
 *              > codigo adaptado a partir de codigo VHDL disponivel em
 *                https://surf-vhdl.com/how-to-design-a-good-edge-detector/
 * ------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      26/01/2024  1.0     Edson Midorikawa  versao inicial
 * ------------------------------------------------------------------------
 */
 
module edge_detector (
    input  clock,
    input  reset,
    input  sinal,
    output pulso
);

    reg reg0;
    reg reg1;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            reg0 <= 1'b0;
            reg1 <= 1'b0;
        end else if (clock) begin
            reg0 <= sinal;
            reg1 <= reg0;
        end
    end

    assign pulso = ~reg1 & reg0;

endmodule
/* --------------------------------------------------------------------------
 *  Arquivo   : gerador_pulso.v
 * --------------------------------------------------------------------------
 *  Descricao : componente parametrizado para geracao de pulso de largura
 *              especificada pelo parametro (em periodos do clock)
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */

module gerador_pulso #(
    parameter largura = 25
) (
    input wire clock,
    input wire reset,
    input wire gera,
    input wire para,
    output reg pulso,
    output reg pronto
);

    // Tipos e sinais
    reg [1:0] reg_estado, prox_estado;
    reg [31:0] reg_cont, prox_cont; // usando 32 bits para acomodar valores maiores de largura

    // Parâmetros para os estados
    localparam parado       = 2'b00;
    localparam contagem     = 2'b01;
    localparam final_pulso  = 2'b10;

    // Lógica de estado e contagem
    always @(posedge clock, posedge reset) begin
        if (reset) begin
            reg_estado <= parado;
            reg_cont <= 0;
        end else begin
            reg_estado <= prox_estado;
            reg_cont <= prox_cont;
        end
    end

    // Lógica de próximo estado e contagem
    always @(*) begin
        pulso = 0;
        pronto = 0;
        prox_cont = reg_cont;

        case (reg_estado)
            parado: begin
                if (gera) begin
                    prox_estado = contagem;
                end else begin
                    prox_estado = parado;
                end
                prox_cont = 0;
            end

            contagem: begin
                if (para) begin
                    prox_estado = parado;
                end else begin
                    if (reg_cont == largura - 1) begin
                        prox_estado = final_pulso;
                    end else begin
                        prox_estado = contagem;
                        prox_cont = reg_cont + 1;
                    end
                end
                pulso = 1;
            end

            final_pulso: begin
                prox_estado = parado;
                pronto = 1;
            end
        endcase
    end

endmodule/* ----------------------------------------------------------------
 * Arquivo   : hexa7seg.v
 * Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
 *--------------------------------------------------------------
 * Descricao : decodificador hexadecimal para 
 *             display de 7 segmentos 
 * 
 * entrada : hexa - codigo binario de 4 bits hexadecimal
 * saida   : sseg - codigo de 7 bits para display de 7 segmentos
 *
 * baseado no componente bcd7seg.v da Intel FPGA
 *--------------------------------------------------------------
 * dica de uso: mapeamento para displays da placa DE0-CV
 *              bit 6 mais significativo é o bit a esquerda
 *              p.ex. sseg(6) -> HEX0[6] ou HEX06
 *--------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     24/12/2023  1.0     Edson Midorikawa  criacao
 *--------------------------------------------------------------
 */

module hexa7seg (hexa, display);
    input      [3:0] hexa;
    output reg [6:0] display;

    /*
     *    ---
     *   | 0 |
     * 5 |   | 1
     *   |   |
     *    ---
     *   | 6 |
     * 4 |   | 2
     *   |   |
     *    ---
     *     3
     */
        
    always @(hexa)
    case (hexa)
        4'h0:    display = 7'b1000000;
        4'h1:    display = 7'b1111001;
        4'h2:    display = 7'b0100100;
        4'h3:    display = 7'b0110000;
        4'h4:    display = 7'b0011001;
        4'h5:    display = 7'b0010010;
        4'h6:    display = 7'b0000010;
        4'h7:    display = 7'b1111000;
        4'h8:    display = 7'b0000000;
        4'h9:    display = 7'b0010000;
        4'ha:    display = 7'b0001000;
        4'hb:    display = 7'b0000011;
        4'hc:    display = 7'b1000110;
        4'hd:    display = 7'b0100001;
        4'he:    display = 7'b0000110;
        4'hf:    display = 7'b0001110;
        default: display = 7'b1111111;
    endcase
endmodule
/* --------------------------------------------------------------------------
 *  Arquivo   : interface_hcsr04_fd.v
 * --------------------------------------------------------------------------
 *  Descricao : CODIGO Final DO fluxo de dados do circuito de interface  
 *              com sensor ultrassonico de distancia
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 *      12/09/2025  1.0     T2BB5             versao em Verilog
 * --------------------------------------------------------------------------
 */
 
module interface_hcsr04_fd (
    input wire         clock,
    input wire         pulso,
    input wire         zera,
    input wire         gera,
    input wire         registra,
    output wire        fim_medida,
    output wire        trigger,
    output wire        fim,
    output wire [11:0] distancia
);

    // Sinais internos
    wire [11:0] s_medida;

    // (U1) pulso de 10us (500 clocks)
    gerador_pulso #(
        .largura(500) 
    ) U1 (
        .clock (clock),
        .reset (zera),
        .gera  (gera),
        .para  (zera), 
        .pulso (trigger),
        .pronto(/* completar */)    // (desconectado)
    );

    // (U2) medida em cm (R=2941 clocks)
    contador_cm #(
        .R(2941), 
        .N(12)
    ) U2 (
        .clock  (clock),
        .reset  (zera),
        .pulso  (pulso),
        .digito2(s_medida[11:8]),
        .digito1(s_medida[7:4]),
        .digito0(s_medida[3:0]),
        .fim    (fim),                 // (desconectado)
        .pronto (fim_medida)
    );

    // (U3) registrador
    registrador_n #(
        .N(12)
    ) U3 (
        .clock  (clock),
        .clear  (zera),
        .enable (registra),
        .D      (s_medida),
        .Q      (distancia)
    );

endmodule
/* --------------------------------------------------------------------------
 *  Arquivo   : interface_hcsr04_uc.v
 * --------------------------------------------------------------------------
 *  Descricao : CODIGO Final DA unidade de controle do circuito de 
 *              interface com sensor ultrassonico de distancia
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 *      12/09/2025  1.0     T2BB5             versao em Verilog
 * --------------------------------------------------------------------------
 */
 
module interface_hcsr04_uc (
    input wire       clock,
    input wire       reset,
    input wire       medir,
    input wire       echo,
    input wire       fim_medida,
    output reg       zera,
    output reg       gera,
    output reg       registra,
    output reg       pronto,
    output reg [3:0] db_estado 
);

    // Tipos e sinais
    reg [2:0] Eatual, Eprox; // 3 bits são suficientes para 7 estados

    // Parâmetros para os estados
    parameter inicial       = 3'b000;
    parameter preparacao    = 3'b001;
    parameter envia_trigger = 3'b010;
    parameter espera_echo   = 3'b011;
    parameter medida        = 3'b100;
    parameter armazenamento = 3'b101;
    parameter final_medida  = 3'b110;

    // Estado
    always @(posedge clock, posedge reset) begin
        if (reset) 
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial:        Eprox <= medir ? preparacao : inicial;
            preparacao:     Eprox <= envia_trigger;
            envia_trigger:  Eprox <= espera_echo;
            espera_echo:    Eprox <= echo ? medida : espera_echo;
            medida:         Eprox <= fim_medida ? armazenamento : medida;
            armazenamento:  Eprox <= final_medida;
            final_medida:   Eprox <= medir ? preparacao : final_medida;
            default:        Eprox <= inicial;
        endcase
    end

    // Saídas de controle
    always @(*) begin
        case (Eatual)
            inicial: begin
                zera <= 1'b0;
                gera <= 1'b0;
                registra <= 1'b0;
                pronto <= 1'b0;
            end
            preparacao: begin
                zera <= 1'b1;
                gera <= 1'b0;
                registra <= 1'b0;
                pronto <= 1'b0;
            end
            envia_trigger: begin
                zera <= 1'b0;
                gera <= 1'b1;
                registra <= 1'b0;
                pronto <= 1'b0;
            end
            espera_echo: begin
                zera <= 1'b0;
                gera <= 1'b0;
                registra <= 1'b0;
                pronto <= 1'b0;
            end
            medida: begin
                zera <= 1'b0;
                gera <= 1'b0;
                registra <= 1'b0;
                pronto <= 1'b0;
            end
            armazenamento: begin
                zera <= 1'b0;
                gera <= 1'b0;
                registra <= 1'b1;
                pronto <= 1'b0;
            end
            final_medida: begin
                zera <= 1'b0;
                gera <= 1'b0;
                registra <= 1'b0;
                pronto <= 1'b1;
            end
            default: begin
                zera <= 1'b0;
                gera <= 1'b0;
                registra <= 1'b0;
                pronto <= 1'b0;
            end
        endcase

        /* completar para outras saidas */

        case (Eatual)
            inicial:       db_estado = 4'b0000;
            preparacao:    db_estado = 4'b0001;
            envia_trigger: db_estado = 4'b0010;
            espera_echo:   db_estado = 4'b0011;
            medida:        db_estado = 4'b0100;
            armazenamento: db_estado = 4'b0101;
            final_medida:  db_estado = 4'b1111;
            default:       db_estado = 4'b1110;
        endcase
    end

endmodule
/* --------------------------------------------------------------------------
 *  Arquivo   : interface_hcsr04.v
 * --------------------------------------------------------------------------
 *  Descricao : circuito de interface com sensor ultrassonico de distancia
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */
 
module interface_hcsr04 (
    input wire         clock,
    input wire         reset,
    input wire         medir,
    input wire         echo,
    output wire        trigger,
    output wire [11:0] medida,
    output wire        pronto,
    output wire [3:0]  db_estado
);

    // Sinais internos
    wire        s_zera;
    wire        s_gera;
    wire        s_registra;
    wire        s_fim_medida;
    wire [11:0] s_medida;

    // Unidade de controle
    interface_hcsr04_uc U1 (
        .clock     (clock       ),
        .reset     (reset       ),
        .medir     (medir       ),
        .echo      (echo        ),
        .fim_medida(s_fim_medida),
        .zera      (s_zera      ),
        .gera      (s_gera      ),
        .registra  (s_registra  ),
        .pronto    (pronto      ),
        .db_estado (db_estado   )
    );

    // Fluxo de dados
    interface_hcsr04_fd U2 (
        .clock     (clock       ),
        .pulso     (echo        ), 
        .zera      (s_zera      ),
        .gera      (s_gera      ),
        .registra  (s_registra  ),
        .fim_medida(s_fim_medida),
        .trigger   (trigger     ),
        .fim       (            ),  // (desconectado)
        .distancia (s_medida    )
    );

    // Saída
    assign medida = s_medida; 

endmodule
/*------------------------------------------------------------------------
 * Arquivo   : mux2x1.v
 * Projeto   : Jogo do Desafio da Memoria
 *------------------------------------------------------------------------
 * Descricao : multiplexador 3x1
 * 
 * adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL"
 * 
 * exemplo de uso: ver testbench mux3x1_tb.v
 *------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     15/02/2024  1.0     Edson Midorikawa  criacao
 *     31/01/2025  1.1     Edson Midorikawa  revisao
 *------------------------------------------------------------------------
 */

module mux2x1 #(
    parameter N = 7
) (
    input [N-1:0] D0,
    input [N-1:0] D1,
    input SEL,
    output reg [N-1:0] OUT
);

always @(*) begin
    case (SEL)
        1'b0:    OUT = D0;
        1'b1:    OUT = D1;
        default: OUT = {N{1'b0}};
    endcase
end

endmodule
/*------------------------------------------------------------------------
 * Arquivo   : mux2x1.v
 * Projeto   : Jogo do Desafio da Memoria
 *------------------------------------------------------------------------
 * Descricao : multiplexador 3x1
 * 
 * adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL"
 * 
 * exemplo de uso: ver testbench mux3x1_tb.v
 *------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     15/02/2024  1.0     Edson Midorikawa  criacao
 *     31/01/2025  1.1     Edson Midorikawa  revisao
 *------------------------------------------------------------------------
 */

module mux3x1 (
    input [6:0] D0,
    input [6:0] D1,
    input [6:0] D2,
    input [1:0] SEL,
    output reg [6:0] OUT
);

always @(*) begin
    case (SEL)
        2'b00:    OUT = D0;
        2'b01:    OUT = D1;
        2'b10:    OUT = D2;
        default: OUT = 4'b0; // saida em 1
    endcase
end

endmodule
/*------------------------------------------------------------------------
 * Arquivo   : mux4x1.v
 * Projeto   : Jogo do Desafio da Memoria
 *------------------------------------------------------------------------
 * Descricao : multiplexador 4x1
 *
 * adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL"
 *
 * exemplo de uso: ver testbench mux4x1_tb.v
 *------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     15/02/2024  1.0     Edson Midorikawa  criacao
 *     31/01/2025  1.1     Edson Midorikawa  revisao
 *------------------------------------------------------------------------
 */

module mux4x1 #(
    parameter N = 7
) (
    input [N-1:0] D0,
    input [N-1:0] D1,
    input [N-1:0] D2,
    input [N-1:0] D3,
    input [1:0] SEL,
    output reg [N-1:0] OUT
);

always @(*) begin
    case (SEL)
        2'b00:    OUT = D0;
        2'b01:    OUT = D1;
        2'b10:    OUT = D2;
        2'b11:    OUT = D3;
        default: OUT = {N{1'b0}};
    endcase
end

endmodule
/*------------------------------------------------------------------------
 * Arquivo   : mux2x1.v
 * Projeto   : Jogo do Desafio da Memoria
 *------------------------------------------------------------------------
 * Descricao : multiplexador 8x1
 * 
 * adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL"
 * 
 * exemplo de uso: ver testbench mux3x1_tb.v
 *------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     15/02/2024  1.0     Edson Midorikawa  criacao
 *     31/01/2025  1.1     Edson Midorikawa  revisao
 *------------------------------------------------------------------------
 */

module mux8x1 (
    input [7:0] D0,
    input [7:0] D1,
    input [7:0] D2,
    input [7:0] D3,
    input [1:0] SEL,
    output reg [7:0] OUT
);

always @(*) begin
    case (SEL)
        2'b00:    OUT = D0;
        2'b01:    OUT = D1;
        2'b10:    OUT = D2;
        2'b11:    OUT = D3;
        default: OUT = 8'b0; // saida em 0
    endcase
end

endmodule
//------------------------------------------------------------------
// Arquivo   : mux_out.v
// Projeto   : Multiplexador de saida
//------------------------------------------------------------------
// Descricao : Multiplexa as saidas dos minigames
//
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/03/2025  1.0     T5BB5             versao inicial
//------------------------------------------------------------------
//

module mux_out (
    input [1:0] minigame,
    input [3:0] estado_0,
    input [6:0] jogada_0,
    input [2:0] pontuacao_0,
    input pronto_0,
    input [3:0] estado_1,
    input [6:0] jogada_1,
    input [2:0] pontuacao_1,
    input pronto_1,
    input [3:0] estado_2,
    input [6:0] jogada_2,
    input [2:0] pontuacao_2,
    input pronto_2,
    input [3:0] estado_inicial,
    output reg [3:0] estado_out,
    output reg [6:0] jogada_out,
    output reg [2:0] pontuacao_out,
    output reg pronto_out
);

always @(*) begin
    case (minigame)
        2'b00: begin
            estado_out = estado_0;
            jogada_out = jogada_0;
            pontuacao_out = pontuacao_0;
            pronto_out = pronto_0;
        end
        2'b01: begin
            estado_out = estado_1;
            jogada_out = jogada_1;
            pontuacao_out = pontuacao_1;
            pronto_out = pronto_1;
        end
        2'b10: begin
            estado_out = estado_2;
            jogada_out = jogada_2;
            pontuacao_out = pontuacao_2;
            pronto_out = pronto_2;
        end
        2'b11: begin
            jogada_out = 7'b0;
            estado_out = estado_inicial;
            pontuacao_out = 3'b0;
            pronto_out = 1'b0;
        end
        default: begin
            estado_out = 4'b0;
            jogada_out = 7'b0;
            pontuacao_out = 3'b0;
            pronto_out = 1'b0;
        end
    endcase
end
    
endmodule

module random #(
  parameter N = 3,           // 2 or 3 bits
  parameter LFSR_SIZE = 7    // Period = 127 cycles (for N=3)
) (
  input clock,
  input reset,
  input write_enable,
  output [N-1:0] address
);

// LFSR state and seed initialization
reg [LFSR_SIZE-1:0] lfsr;
reg [LFSR_SIZE-1:0] seed;

initial begin
    seed <= 0;
    lfsr <= {LFSR_SIZE{1'b1}};
end

// LFSR feedback polynomial (x^7 + x^6 + 1)
wire feedback = lfsr[LFSR_SIZE-1] ^ lfsr[LFSR_SIZE-2];

always @(posedge clock or posedge reset) begin
  if (reset) begin
    lfsr <= {seed, 1'b1};   // Avoid zero initialization
    seed <= seed + 1;
  end
  else if (write_enable) begin
    lfsr <= {lfsr[LFSR_SIZE-2:0], feedback};
  end
end

// Bijective mapping: Ensure all 2^N combinations appear
assign address = lfsr[N-1:0] ^ lfsr[LFSR_SIZE-1:LFSR_SIZE-N];

endmodule
//------------------------------------------------------------------
// Arquivo   : registrador_4.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle 
//------------------------------------------------------------------
// Descricao : Registrador de 4 bits
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//
module registrador_4 (
    input        clock,
    input        clear,
    input        enable,
    input  [6:0] D,
    output [6:0] Q
);

    reg [6:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule/* -----------------Laboratorio Digital-----------------------------------
 *  Arquivo   : registrador_n.v
 * -----------------------------------------------------------------------
 *  Descricao : registrador com numero de bits N como parametro
 *              com clear assincrono e carga sincrona
 * 
 *              baseado no codigo vreg16.v do livro
 *              J. Wakerly, Digital design: principles and practices 5e
 *
 * -----------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      11/01/2024  1.0     Edson Midorikawa  criacao
 * -----------------------------------------------------------------------
 */
 
module registrador_n #(parameter N = 8) (
    input          clock,
    input          clear,
    input          enable,
    input  [N-1:0] D,
    output [N-1:0] Q
);

    reg [N-1:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule
//------------------------------------------------------------------
// Arquivo   : sync_cake_rom.v
// Projeto   : BitBakery 
//------------------------------------------------------------------
// Descricao : ROM sincrona 16x4 (conteúdo pre-programado)
//              Memoria para diferentes bolos
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//     22/03/2025  1.0     T5BB5             versao final
//------------------------------------------------------------------
//
module rom_easy (clock, address, data_out);
    input            clock;
    input      [1:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            2'b00: data_out = 7'b0000001;
            2'b01: data_out = 7'b0000010;
            2'b10: data_out = 7'b0000100;
            2'b11: data_out = 7'b0001000;
        endcase
    end
endmodule

//------------------------------------------------------------------
// Arquivo   : sync_cake_rom.v
// Projeto   : BitBakery 
//------------------------------------------------------------------
// Descricao : ROM sincrona 16x4 (conteúdo pre-programado)
//              Memoria para diferentes bolos
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//     22/03/2025  1.0     T5BB5             versao final
//------------------------------------------------------------------
//
module rom (clock, address, data_out);
    input            clock;
    input      [2:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            3'b000: data_out = 7'b0000001;
            3'b001: data_out = 7'b0000010;
            3'b010: data_out = 7'b0000100;
            3'b011: data_out = 7'b0001000;
            3'b100: data_out = 7'b0010000;
            3'b101: data_out = 7'b0100000;
            3'b110: data_out = 7'b0000001;
            3'b111: data_out = 7'b0000010;
        endcase
    end
endmodule


module sync_ram (
    input clock,
    input reset,
    input write_enable,
    input [3:0] address,
    input [6:0] data_in,
    output reg [6:0] data_out
);

reg [6:0] ram [15:0];
integer i;

always @ (posedge clock or posedge reset) begin
    if (reset)
        for (i = 0; i < 16; i = i + 1)
            ram[i] <= 7'b0;
    else begin
        if (write_enable)
            ram[address] <= data_in;
        data_out <= ram[address];
    end
end
    
endmodule
//------------------------------------------------------------------
// Arquivo   : sync_rom_16x4.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle 
//------------------------------------------------------------------
// Descricao : ROM sincrona 16x4 (conteúdo pre-programado)
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//
module sync_rom_16x4_mem2 (clock, address, data_out);
    input            clock;
    input      [3:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            4'b0000: data_out = 7'b0010000; //1
            4'b0001: data_out = 7'b0100000; //2
            4'b0010: data_out = 7'b0100000; //3
            4'b0011: data_out = 7'b0001000; //4
            4'b0100: data_out = 7'b0000001; //5
            4'b0101: data_out = 7'b0000010; //6
            4'b0110: data_out = 7'b0000010; //7
            4'b0111: data_out = 7'b0000100; //8
            4'b1000: data_out = 7'b0100000; //9
            4'b1001: data_out = 7'b0001000; //10
            4'b1010: data_out = 7'b0000100; //11
            4'b1011: data_out = 7'b0010000; //12
            4'b1100: data_out = 7'b0000001; //13
            4'b1101: data_out = 7'b0100000; //14
            4'b1110: data_out = 7'b0010000; //15
            4'b1111: data_out = 7'b0000100; //16
        endcase
    end
endmodule

//------------------------------------------------------------------
// Arquivo   : sync_rom_16x4.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle 
//------------------------------------------------------------------
// Descricao : ROM sincrona 16x4 (conteúdo pre-programado)
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//
module sync_rom_16x4 (clock, address, data_out);
    input            clock;
    input      [3:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            4'b0000: data_out = 7'b0001000; //1
            4'b0001: data_out = 7'b0010000; //2
            4'b0010: data_out = 7'b0100000; //3
            4'b0011: data_out = 7'b0000100; //4
            4'b0100: data_out = 7'b0000001; //5
            4'b0101: data_out = 7'b0000001; //6
            4'b0110: data_out = 7'b0001000; //7
            4'b0111: data_out = 7'b0000010; //8
            4'b1000: data_out = 7'b0100000; //9
            4'b1001: data_out = 7'b0000001; //10
            4'b1010: data_out = 7'b0000100; //11
            4'b1011: data_out = 7'b0000010; //12
            4'b1100: data_out = 7'b0001000; //13
            4'b1101: data_out = 7'b0100000; //14
            4'b1110: data_out = 7'b0010000; //15
            4'b1111: data_out = 7'b0010000; //16
        endcase
    end
endmodule

/* -------------------------------------------------------------
 * Arquivo   : tx_serial_8E1_fd.v
 *--------------------------------------------------------------
 * Descricao : fluxo de dados do circuito base de transmissao 
 *             serial assincrona (8E1) 
 *             ==> contem deslocador com 11 bits e contador
 *                 modulo 12
 * 
 *--------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     30/08/2025  1.0     Edson Midorikawa  criacao
 *     03/11/2025  2.0     Thaylor Hugo      conversao para 8E1
 *     04/11/2025  2.1     Thaylor Hugo      correcao bit ordering
 *--------------------------------------------------------------
 */
 
 module tx_serial_8E1_fd (
    input        clock        ,
    input        reset        ,
    input        zera         ,
    input        conta        ,
    input        carrega      ,
    input        desloca      ,
    input  [7:0] dados_ascii  ,
    output       saida_serial ,
    output       fim
);

    wire [11:0] s_dados;
    wire [11:0] s_saida;
    wire s_paridade;

    // Calculo da paridade
    xor_paridade xor_paridade (
        .dados    (dados_ascii),
        .paridade (s_paridade)
    );

    // composicao dos dados seriais (8E1)
    // Formato: [idle][start][D0][D1][D2][D3][D4][D5][D6][D7][parity][stop]
    assign s_dados[0]   = 1'b1;             // idle state
    assign s_dados[1]   = 1'b0;             // start bit
    assign s_dados[2]   = dados_ascii[0];   // bit 0 (LSB)
    assign s_dados[3]   = dados_ascii[1];   // bit 1
    assign s_dados[4]   = dados_ascii[2];   // bit 2
    assign s_dados[5]   = dados_ascii[3];   // bit 3
    assign s_dados[6]   = dados_ascii[4];   // bit 4
    assign s_dados[7]   = dados_ascii[5];   // bit 5
    assign s_dados[8]   = dados_ascii[6];   // bit 6
    assign s_dados[9]   = dados_ascii[7];   // bit 7 (MSB)
    assign s_dados[10]  = s_paridade;       // even parity bit
    assign s_dados[11]  = 1'b1;             // stop bit
  
    // Instanciação do deslocador_n
    deslocador_n #(
        .N(12) 
    ) U1 (
        .clock         (clock  ),
        .reset         (reset  ),
        .carrega       (carrega),
        .desloca       (desloca),
        .entrada_serial(1'b1   ), // stop bit comes from shift register fill
        .dados         (s_dados),
        .saida         (s_saida)
    );
    
    // Instanciação do contador_m
    contador_m #(
        .M(12),
        .N(4)
    ) U2 (
        .clock   (clock),
        .zera_as (1'b0 ),
        .zera_s  (zera ),
        .conta   (conta),
        .Q       (     ), // porta Q em aberto (desconectada)
        .fim     (fim  ),
        .meio    (     )  // porta meio em aberto (desconectada)
    );
    
    // Saida serial do transmissor
    assign saida_serial = s_saida[0];
  
endmodule
/* -------------------------------------------------------------
 * Arquivo   : tx_serial_8N1.v
 *--------------------------------------------------------------
 * Descricao : circuito base de transmissao serial assincrona 
 *             ==> comunicacao serial de 7 bits de dados, 
 *                 sem partidade, 2 stop bits e 115200 bauds
 * 
 * entradas : partida, dados_ascii
 * saidas   : saida_serial, pronto
 * depuracao: db_clock, db_tick, db_partida, db_saida_serial
 *            e db_estado
 *
 *--------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     30/08/2025  1.0     Edson Midorikawa  criacao
 *--------------------------------------------------------------
 */

module tx_serial_8E1 (
    input        clock           ,
    input        reset           ,
    input        partida         , // entradas
    input [7:0]  dados_ascii     ,
    output       saida_serial    , // saidas
    output       pronto          ,
    output       db_clock        , // saidas de depuracao
    output       db_tick         ,
    output       db_partida      ,
    output       db_saida_serial ,
    output [6:0] db_estado       
);
 
    wire       s_reset        ;
    wire       s_partida      ;
    wire       s_partida_ed   ;
    wire       s_zera         ;
    wire       s_conta        ;
    wire       s_carrega      ;
    wire       s_desloca      ;
    wire       s_tick         ;
    wire       s_fim          ;
    wire       s_saida_serial ;
    wire [3:0] s_estado       ;

	 // sinais reset e partida (ativos em alto - GPIO)
    assign s_reset   = reset;
    assign s_partida = partida;
	 
    // fluxo de dados
    tx_serial_8E1_fd U1_FD (
        .clock        ( clock          ),
        .reset        ( s_reset        ),
        .zera         ( s_zera         ),
        .conta        ( s_conta        ),
        .carrega      ( s_carrega      ),
        .desloca      ( s_desloca      ),
        .dados_ascii  ( dados_ascii    ),
        .saida_serial ( s_saida_serial ),
        .fim          ( s_fim          )
    );


    // unidade de controle
    tx_serial_uc U2_UC (
        .clock     ( clock        ),
        .reset     ( s_reset      ),
        .partida   ( s_partida_ed ),
        .tick      ( s_tick       ),
        .fim       ( s_fim        ),
        .zera      ( s_zera       ),
        .conta     ( s_conta      ),
        .carrega   ( s_carrega    ),
        .desloca   ( s_desloca    ),
        .pronto    ( pronto       ),
        .db_estado ( s_estado     )
    );

    // gerador de tick
    // fator de divisao para 9600 bauds (5208=50M/9600) 13 bits
    // fator de divisao para 115.200 bauds (434=50M/115200) 9 bits
    contador_m #(
        .M(434), 
        .N(9) 
     ) U3_TICK (
        .clock   ( clock  ),
        .zera_as ( 1'b0   ),
        .zera_s  ( s_zera ),
        .conta   ( 1'b1   ),
        .Q       (        ),
        .fim     ( s_tick ),
        .meio    (        )
    );


    // detetor de borda para tratar pulsos largos
    edge_detector U4_ED (
        .clock ( clock        ),
        .reset ( reset        ),
        .sinal ( s_partida    ),
        .pulso ( s_partida_ed )
    );


    // saida serial
    assign saida_serial = s_saida_serial;

    // depuracao
    assign db_clock        = clock;
    assign db_tick         = s_tick;
    assign db_partida      = s_partida;
    assign db_saida_serial = s_saida_serial;

    // hexa0
    hexa7seg HEX0 ( 
        .hexa    ( s_estado  ), 
        .display ( db_estado )
    );
  
endmodule
/* ----------------------------------------------------------------
 * Arquivo   : tx_serial_uc.v
 * Projeto   : Experiencia 2 - Transmissao Serial Assincrona
 * ----------------------------------------------------------------
 * Descricao : unidade de controle do circuito da experiencia 2 
 * => implementa superamostragem (tick)
 * => independente da configuracao de transmissao (7O1, 8N2, etc)
 * ----------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     09/09/2021  1.0     Edson Midorikawa  versao inicial em VHDL
 *     27/08/2024  4.0     Edson Midorikawa  conversao para Verilog
 *     30/08/2025  4.1     Edson Midorikawa  revisao
 * ----------------------------------------------------------------
 */

module tx_serial_uc ( 
    input      clock          ,
    input      reset          ,
    input      partida        ,
    input      tick           ,
    input      fim            ,
    output reg zera           ,
    output reg conta          ,
    output reg carrega        ,
    output reg desloca        ,
    output reg pronto         ,
    output reg [3:0] db_estado
);

    // Estados da UC
    parameter inicial     = 4'b0000; 
    parameter preparacao  = 4'b0001; 
    parameter espera      = 4'b0011; 
    parameter transmissao = 4'b0111; 
    parameter final_tx    = 4'b1111;

    // Variaveis de estado
    reg [3:0] Eatual, Eprox;

    // Memoria de estado
    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    // Logica de proximo estado
    always @* begin
        case (Eatual)
            inicial     : Eprox = partida ? preparacao : inicial;
            preparacao  : Eprox = espera;
            espera      : Eprox = tick ? transmissao : ( fim ? final_tx : espera );
            transmissao : Eprox = fim ? final_tx : espera;
            final_tx    : Eprox = inicial;
            default     : Eprox = inicial;
        endcase
    end

    // Logica de saida (maquina de Moore)
    always @* begin
        carrega = (Eatual == preparacao) ? 1'b1 : 1'b0;
        zera    = (Eatual == preparacao) ? 1'b1 : 1'b0;
        desloca = (Eatual == transmissao) ? 1'b1 : 1'b0;
        conta   = (Eatual == transmissao) ? 1'b1 : 1'b0;
        pronto  = (Eatual == final_tx) ? 1'b1 : 1'b0;

        // Saida de depuracao (estado)
        case (Eatual)
            inicial     : db_estado = 4'b0000; // 0
            preparacao  : db_estado = 4'b0001; // 1
            espera      : db_estado = 4'b0011; // 3
            transmissao : db_estado = 4'b0111; // 7
            final_tx    : db_estado = 4'b1111; // F
            default     : db_estado = 4'b1110; // E
        endcase
    end

endmodule
module xor_paridade (
    input wire [7:0] dados,
    output wire paridade
);
    assign paridade = ^dados;
endmodule
/*---------------Laboratorio Digital-------------------------------------
 * Arquivo   : contador_max.v
 * Projeto   : Experiencia 4 - Desenvolvimento de Projeto de 
 *                             Circuitos Digitais em FPGA
 *-----------------------------------------------------------------------
 * Descricao : contador binario, modulo m, com parametros 
 *             M (modulo do contador) e N (numero de bits),
 *             sinais para clear assincrono (zera_as) e sincrono (zera_s)
 *             e saidas de fim e meio de contagem
 * Finaliza contagem ao atingir valor maximo M-1
 *             
 *-----------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     30/01/2024  1.0     Edson Midorikawa  criacao
 *     16/01/2025  1.1     Edson Midorikawa  revisao
 *-----------------------------------------------------------------------
 */

module contador_max #(parameter M=100, N=7)
  (
   input  wire          clock,
   input  wire          zera_as,
   input  wire          zera_s,
   input  wire          conta,
   output reg  [N-1:0]  Q,
   output reg           fim,
   output reg           meio
  );

  always @(posedge clock or posedge zera_as) begin
    if (zera_as) begin
      Q <= 0;
    end else if (clock) begin
      if (zera_s) begin
        Q <= 0;
      end else if (conta && !fim) begin
        if (Q == M-1) begin
          Q <= 0;
        end else begin
          Q <= Q + 1'b1;
        end
      end
    end
  end

  // Saidas
  always @ (Q)
      if (Q == M-1)   fim = 1;
      else            fim = 0;

  always @ (Q)
      if (Q == M/2-1) meio = 1;
      else            meio = 0;

endmodule

module delivery_game_fd (
    input clock,
    input reset,
    input [6:0] botoes,
    input echo,
    input count_map,
    input get_velocity,
    output [2:0] pontuacao,
    output game_over,
    output pwm,
    output trigger,
    output velocity_ready,
    output [3:0] db_player_position,
    output [63:0] db_map_obstacle,
    output [63:0] db_map_objective
);

reg [3:0] player_position;
wire s_sel_obstacle, s_sel_objective, s_move_map, s_count_points;
wire [11:0] s_medida;
wire [1:0] s_velocity;
wire [63:0] s_map_obstacles_flat, s_map_objectives_flat;
wire s_obstacle_generated, s_objective_generated;
integer i;
integer k;

assign db_player_position = player_position;
assign db_map_obstacle = s_map_obstacles_flat;
assign db_map_objective = s_map_objectives_flat;


initial begin
    player_position <= 4'b1000; // Starting position
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        // Reset player position and map
        player_position <= 4'b1000;
    end else begin
        // Update player position based on button inputs
        if (botoes[0] && player_position != 4'b1000) player_position <= player_position << 1; // Move left
        else if (botoes[1] && player_position != 4'b0001) player_position <= player_position >> 1; // Move right
    end
end

assign game_over = ((s_map_obstacles_flat[3:0] & player_position) == 4'h0)? 1'b0 : 1'b1;

contador_m #(
    .M(30_000), // Every 30s
    .N(32)
) pontuacao_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_move_map),
    .Q (),
    .fim (s_count_points),
    .meio ()
);

contador_max #(
    .M(7),
    .N(3)
) velocity_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_count_points),
    .Q (pontuacao),
    .fim (),
    .meio ()
);

contador_m #(
    .M(3),
    .N(2)
) place_obstacle_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_move_map),
    .Q (),
    .fim (s_sel_obstacle),
    .meio ()
);

contador_m #(
    .M(6),
    .N(3)
) place_objective_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_move_map),
    .Q (),
    .fim (s_sel_objective),
    .meio ()
);

generate_map map_gen (
    .clock (clock),
    .reset (reset),
    .move_map (s_move_map),
    .sel_obstacle (s_sel_obstacle),
    .sel_objective (1'b0 /*s_sel_objective*/),
    .map_obstacles_flat (s_map_obstacles_flat),
    .map_objectives_flat (s_map_objectives_flat),
    .obstacle_generated (s_obstacle_generated),
    .objective_generated (s_objective_generated)
);

// Circuito de interface com sensor
interface_hcsr04 ultrassonico (
    .clock    (clock),
    .reset    (reset),
    .medir    (get_velocity),
    .echo     (echo),
    .trigger  (trigger),
    .medida   (s_medida),
    .pronto   (velocity_ready),
    .db_estado()
);

// Map velocity counters
assign s_velocity = (s_medida <= 12'h004) ? 2'b11 :
                    (s_medida <= 12'h008) ? 2'b10 :
                    (s_medida <= 12'h012) ? 2'b01 : 2'b00;

map_counter map_counter_inst (
    .clock (clock),
    .reset (reset),
    .count_map (count_map),
    .velocity (s_velocity),
    .move_map (s_move_map)
);

endmodule
module delivery_game_uc (
    input clock,
    input reset,
    input jogar,
    input game_over,
    input velocity_ready,
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

endmodule// Delivery Game Module

module delivery_game (
    input clock,
    input reset,
    input jogar,
    input [6:0] botoes,
    input echo,
    output [3:0] estado,
    output [2:0] pontuacao,
    output pronto,
    output pwm,
    output trigger,
    output [3:0] db_player_position,
    output [63:0] db_map_obstacle,
    output [63:0] db_map_objective
);

wire s_reset, s_game_over, s_count_map, s_get_velocity, s_velocity_ready;

delivery_game_fd fd (
    .clock (clock),
    .reset (s_reset),
    .botoes(botoes),
    .echo (echo),
    .count_map (s_count_map),
    .get_velocity (s_get_velocity),
    .pontuacao (pontuacao),
    .game_over (s_game_over),
    .pwm (pwm),
    .trigger (trigger),
    .velocity_ready (s_velocity_ready),
    .db_player_position (db_player_position),
    .db_map_obstacle (db_map_obstacle),
    .db_map_objective (db_map_objective)
);

delivery_game_uc uc (
    .clock (clock),
    .reset (reset),
    .jogar (jogar),
    .game_over (s_game_over),
    .velocity_ready (s_velocity_ready),
    .estado (estado),
    .reset_out (s_reset),
    .pronto (pronto),
    .count_map (s_count_map),
    .get_velocity (s_get_velocity)
);


endmodule// Rom for generating delivery game patterns

module delivery_rom (clock, address, data_out);
    input            clock;
    input      [3:0] address;
    output reg [3:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            4'b0000: data_out = 4'b0001;
            4'b0001: data_out = 4'b0010;
            4'b0010: data_out = 4'b0100;
            4'b0011: data_out = 4'b1000;
            4'b0100: data_out = 4'b1001;
            4'b0101: data_out = 4'b1010;
            4'b0110: data_out = 4'b1100;
            4'b0111: data_out = 4'b0110;
            4'b1000: data_out = 4'b0101;
            4'b1001: data_out = 4'b0011;
            4'b1010: data_out = 4'b1110;
            4'b1011: data_out = 4'b1101;
            4'b1100: data_out = 4'b1011;
            4'b1101: data_out = 4'b0111;
            4'b1110: data_out = 4'b1000;
            4'b1111: data_out = 4'b0110;
        endcase
    end
endmodule
// Module that generates and moves the map for the delivery game

module generate_map (
    input clock,
    input reset,
    input move_map,
    input sel_obstacle,     // 1 for obstacle, 0 for no obstacle
    input sel_objective,    // 1 for objective, 0 for no objective
    output [63:0] map_obstacles_flat,
    output [63:0] map_objectives_flat,
    output reg obstacle_generated,  // Pulses when obstacle is inserted
    output reg objective_generated  // Pulses when objective is inserted
);

reg [3:0] map_obstacles [0:15];
reg [3:0] map_objectives [0:15];

wire [3:0] s_random_obstacles_address, s_random_objectives_address;
wire [3:0] s_random_obstacle, s_random_objective;
wire [3:0] s_selected_obstacle, s_selected_objective;
integer i;

initial begin
    // Initialize map obstacles and objectives
    for (i = 0; i < 16; i = i + 1) begin
        map_obstacles[i] <= 4'b0000;
        map_objectives[i] <= 4'b0000;
    end
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 16; i = i + 1) begin
            map_obstacles[i] <= 4'b0000;
            map_objectives[i] <= 4'b0000;
        end
        obstacle_generated <= 1'b0;
        objective_generated <= 1'b0;
    end else if (move_map) begin
        // Shift map down
        for (i = 0; i < 15; i = i + 1) begin
            map_obstacles[i] <= map_obstacles[i+1];
            map_objectives[i] <= map_objectives[i+1];
        end
        // Insert new obstacles and objectives at the top
        map_obstacles[15] <= s_selected_obstacle;
        map_objectives[15] <= s_selected_objective;
        
        // Generate feedback signals
        obstacle_generated <= sel_obstacle && (s_selected_obstacle != 4'b0000);
        objective_generated <= sel_objective && (s_selected_objective != 4'b0000);
    end else begin
        // Clear feedback signals when not moving
        obstacle_generated <= 1'b0;
        objective_generated <= 1'b0;
    end
end

random_4 random_obstacles (
    .clock          (clock),
    .reset          (reset),
    .write_enable   (1'b1),
    .address        (s_random_obstacles_address)
);

random_4 random_objectives (
    .clock          (clock),
    .reset          (reset),
    .write_enable   (1'b1),
    .address        (s_random_objectives_address)
);

delivery_rom rom_obstacles (
    .clock (clock),
    .address (s_random_obstacles_address),
    .data_out (s_random_obstacle)
);

delivery_rom rom_objectives (
    .clock (clock),
    .address (s_random_objectives_address),
    .data_out (s_random_objective)
);

mux2x1 #(.N(4)) mux_obstacles (
    .D0 (4'b0000),
    .D1 (s_random_obstacle[3:0]),
    .SEL (sel_obstacle),
    .OUT (s_selected_obstacle)
);

mux2x1 #(.N(4)) mux_objectives (
    .D0 (4'b0000),
    .D1 (s_random_objective[3:0]),
    .SEL (sel_objective),
    .OUT (s_selected_objective)
);

assign map_obstacles_flat[3:0] = map_obstacles[0];
assign map_objectives_flat[3:0] = map_objectives[0];
assign map_obstacles_flat[7:4] = map_obstacles[1];
assign map_objectives_flat[7:4] = map_objectives[1];
assign map_obstacles_flat[11:8] = map_obstacles[2];
assign map_objectives_flat[11:8] = map_objectives[2];
assign map_obstacles_flat[15:12] = map_obstacles[3];
assign map_objectives_flat[15:12] = map_objectives[3];
assign map_obstacles_flat[19:16] = map_obstacles[4];
assign map_objectives_flat[19:16] = map_objectives[4];
assign map_obstacles_flat[23:20] = map_obstacles[5];
assign map_objectives_flat[23:20] = map_objectives[5];
assign map_obstacles_flat[27:24] = map_obstacles[6];
assign map_objectives_flat[27:24] = map_objectives[6];
assign map_obstacles_flat[31:28] = map_obstacles[7];
assign map_objectives_flat[31:28] = map_objectives[7];
assign map_obstacles_flat[35:32] = map_obstacles[8];
assign map_objectives_flat[35:32] = map_objectives[8];
assign map_obstacles_flat[39:36] = map_obstacles[9];
assign map_objectives_flat[39:36] = map_objectives[9];
assign map_obstacles_flat[43:40] = map_obstacles[10];
assign map_objectives_flat[43:40] = map_objectives[10];
assign map_obstacles_flat[47:44] = map_obstacles[11];
assign map_objectives_flat[47:44] = map_objectives[11];
assign map_obstacles_flat[51:48] = map_obstacles[12];
assign map_objectives_flat[51:48] = map_objectives[12];
assign map_obstacles_flat[55:52] = map_obstacles[13];
assign map_objectives_flat[55:52] = map_objectives[13];
assign map_obstacles_flat[59:56] = map_obstacles[14];
assign map_objectives_flat[59:56] = map_objectives[14];
assign map_obstacles_flat[63:60] = map_obstacles[15];
assign map_objectives_flat[63:60] = map_objectives[15];

endmodule// BUG: missed move_map signal depending on right change of velocity input

module map_counter (
    input clock,
    input reset,
    input count_map,
    input [1:0] velocity,
    output move_map
);

wire s_move_map_800, s_move_map_700, s_move_map_600, s_move_map_500, s_move_map_400, s_move_map_300, s_move_map_200;
wire [1:0] s_base_velocity;
wire s_max_velocity, s_increment_velocity;

velocity_mux velocity_selector (
    .v0 (s_move_map_800),
    .v1 (s_move_map_700),
    .v2 (s_move_map_600),
    .v3 (s_move_map_500),
    .v4 (s_move_map_400),
    .v5 (s_move_map_300),
    .v6 (s_move_map_200),
    .sel_base (s_base_velocity),
    .sel_player (velocity),
    .out (move_map)
);

contador_m #(
    .M(30_000), // 30 seconds at 1kHz
    .N(16)
) increment_velocity_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_increment_velocity),
    .meio ()
);

contador_max #(
    .M(4),
    .N(2)
) base_velocity_counter (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (s_increment_velocity),
    .Q (s_base_velocity),
    .fim (s_max_velocity),
    .meio ()
);

contador_m #(
    .M(800), // 0.8 seconds at 1kHz
    .N(16)
) map_timer_800 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_800),
    .meio ()
);

contador_m #(
    .M(700), // 0.7 seconds at 1kHz
    .N(16)
) map_timer_700 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_700),
    .meio ()
);

contador_m #(
    .M(600), // 0.6 seconds at 1kHz
    .N(16)
) map_timer_600 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_600),
    .meio ()
);

contador_m #(
    .M(500), // 0.5 seconds at 1kHz
    .N(16)
) map_timer_500 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_500),
    .meio ()
);

contador_m #(
    .M(400), // 0.4 seconds at 1kHz
    .N(16)
) map_timer_400 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_400),
    .meio ()
);

contador_m #(
    .M(300), // 0.3 seconds at 1kHz
    .N(16)
) map_timer_300 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_300),
    .meio ()
);

contador_m #(
    .M(200), // 0.2 seconds at 1kHz
    .N(16)
) map_timer_200 (
    .clock (clock),
    .zera_as (1'b0),
    .zera_s (reset),
    .conta (count_map),
    .Q (),
    .fim (s_move_map_200),
    .meio ()
);

endmodule
module random_4 (
  input clock,
  input reset,
  input write_enable,
  output [3:0] address
);

// LFSR state and seed initialization (8-bit LFSR for N=4)
reg [7:0] lfsr;
reg [7:0] seed;

initial begin
    seed = 8'h01;      // Use blocking assignment and non-zero seed
    lfsr = 8'hAA;      // Use blocking assignment with initial pattern
end

// LFSR feedback polynomial for 8-bit (x^8 + x^6 + x^5 + x^4 + 1)
// Maximal length sequence with period 255
wire feedback;
assign feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

always @(posedge clock or posedge reset) begin
  if (reset) begin
    lfsr <= seed | 8'h01;   // Ensure non-zero (OR with 1)
    seed <= seed + 8'h01;
  end
  else if (write_enable) begin
    lfsr <= {lfsr[6:0], feedback};
  end
end

// Bijective mapping: XOR upper and lower 4 bits for better distribution
assign address = lfsr[3:0] ^ lfsr[7:4];

endmodule
module velocity_mux (
    input v0,
    input v1,
    input v2,
    input v3,
    input v4,
    input v5,
    input v6,
    input [1:0] sel_base,
    input [1:0] sel_player,
    output reg out
);

always @(*) begin
    case (sel_base)
        2'b00: begin
            case (sel_player)
                2'b00: out = v0;
                2'b01: out = v1;
                2'b10: out = v2;
                2'b11: out = v3;
            endcase
        end
        2'b01: begin
            case (sel_player)
                2'b00: out = v1;
                2'b01: out = v2;
                2'b10: out = v3;
                2'b11: out = v4;
            endcase
        end
        2'b10: begin
            case (sel_player)
                2'b00: out = v2;
                2'b01: out = v3;
                2'b10: out = v4;
                2'b11: out = v5;
            endcase
        end
        2'b11: begin
            case (sel_player)
                2'b00: out = v3;
                2'b01: out = v4;
                2'b10: out = v5;
                2'b11: out = v6;
            endcase
        end
        // Additional cases can be added here for different base selections
        default: out = v0; // Default case
    endcase
end

endmodule//------------------------------------------------------------------
// Arquivo   : exp3_fluxo_dados.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle 
//------------------------------------------------------------------
// Descricao : Modulo do fluxo de dados da experiencia
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor            Descricao
//     18/01/2025  1.0     T5BB5            versao inicial
//------------------------------------------------------------------
//

module fluxo_dados (
    input clock,
    input zeraE,
    input contaE,
    input zeraL,
    input contaL,
    input zeraR,
    input zeraM,
    input contaM,
    input registraR,
	 input selecionaMemoria,
     input reset_random,
    input [6:0] botoes,
	 input contaT,
    input [1:0] seletor,
    output botoesIgualMemoria,
    output fimE,
    output fimL,
	output meioL,
    output fimM,
    output meioM,
    output endecoIgualLimite,
    output endecoMenorLimite,
    output jogada_feita,
    output [3:0] db_limite,
    output [3:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_jogada,
    output [6:0] leds,
	output timeout

);
    wire [3:0] s_endereco, s_limite;  // sinal interno para interligacao dos componentes
    wire s_jogada;
    wire [6:0] s_dado, s_dado2, s_saida_memorias, s_botoes, s_leds;
    wire sinal = botoes[0] | botoes[1] | botoes[2] | botoes[3];
    wire random_mem;


    // multiplexador 3x1
    mux3x1 mux (

        .D0      (4'b0),
        .D1      (s_saida_memorias),
        .D2      (botoes),
        .SEL     (seletor),
        .OUT     (s_leds)

    );

    random #(.N(2)) random_memory (
        .clock          (clock),
        .reset          (reset_random),
        .write_enable   (selecionaMemoria),
        .address        (random_mem)
    );
	 
	mux2x1 mux_memorias (

        .D0      (s_dado),
        .D1      (s_dado2),
        .SEL     (random_mem),
        .OUT     (s_saida_memorias)
    );


    // contador_163
    contador_163 contador (
        .clock    (clock),
        .clr      (~zeraE),
        .ld       (1'b1),
        .ent      (1'b1),
        .enp      (contaE),
        .D        (4'b0),
        .Q        (s_endereco),
        .rco      (fimE)
    );

   
	 
	 // contador_m
    contador_m  #(.M(16),.N(4)) contadorLmt (
       .clock     (clock),   
       .zera_as   (zeraL),
       .zera_s    (1'b0),
       .conta	  (contaL),
       .Q         (s_limite),
       .fim       (fimL),
       .meio      (meioL)
    );

    // contador_m
    contador_m  #(.M(1000),.N(32)) contadorM (
       .clock     (clock),   
       .zera_as   (zeraM),
       .zera_s    (1'b0),
       .conta	  (contaM),
       .Q         (),
       .fim       (fimM),
       .meio      (meioM)
    );
	 
	 // contador_m
    contador_m  #(.M(5000), .N(64)) contador_timeout (
       .clock     (clock),   
       .zera_as   (~contaT),
       .zera_s    (1'b0),
       .conta	   (contaT),
       .Q         (),
       .fim       (timeout),
       .meio      ()
    );

     // edge_detector
    edge_detector detector (
        .clock      (clock), 
        .reset      (zeraL),
        .sinal      (sinal),
        .pulso      (s_jogada)
    );

    // memoria_rom_16x4
    sync_rom_16x4 rom (
        .clock      (clock),
        .address    (s_endereco),
        .data_out   (s_dado)
    );
	 
	 sync_rom_16x4_mem2 rom_2 (
        .clock      (clock),
        .address    (s_endereco),
        .data_out   (s_dado2)
    );
	 
	 

    // registrador de 4 bits
    registrador_4 registrador (
        .clock  (clock),
        .clear  (zeraR),
        .enable (registraR),
        .D      (botoes),
        .Q      (s_botoes)
    );

    // comparador_85
    comparador comparador (
        .A    (s_saida_memorias),
        .B    (s_botoes),
        .ALBo (    ),
        .AGBo (    ),
        .AEBo (botoesIgualMemoria)
    );
    
    // comparador_85
    comparador_85 comparadorLmt (
        .A    (s_endereco),
        .B    (s_limite),
        .ALBi (1'b0),
        .AGBi (1'b0),
        .AEBi (1'b1),
        .ALBo (endecoMenorLimite),
        .AGBo (    ),
        .AEBo (endecoIgualLimite)
    );

    // saida de depuracao
    assign db_contagem = s_endereco;
    assign db_memoria = s_saida_memorias;
    assign db_jogada = s_botoes;
    assign jogada_feita = s_jogada;
    assign db_limite = s_limite;
    assign leds = s_leds;

 endmodule
//------------------------------------------------------------------
// Arquivo   : exp3_unidade_controle.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
//------------------------------------------------------------------
// Descricao : Unidade de controle
//
// usar este codigo como template (modelo) para codificar 
// máquinas de estado de unidades de controle            
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/01/2024  1.0     Edson Midorikawa  versao inicial
//     12/01/2025  1.1     Edson Midorikawa  revisao
//------------------------------------------------------------------
//

module unidade_controle (
    input clock,
    input reset,
    input iniciar,
    input jogada,
	input timeout,
    input botoesIgualMemoria,
    input fimE,
    input fimL,
	input meioL,
    input enderecoIgualLimite,
    input enderecoMenorLimite,
	input chaveDificuldade,
    input fimM,
    input meioM,
    output reg [1:0] seletor,
    output reg zeraM,
    output reg contaM,
    output reg zeraE,
    output reg contaE,
    output reg zeraL,
    output reg contaL,
    output reg zeraR,
    output reg registraR,
    output reg acertou,
    output reg errou,
    output reg pronto,
    output reg fim_timeout,
    output reg [3:0] db_estado,
	 output reg contaT,
	 output reg seletorMemoria,
     output reg reset_random,
	 output  db_dificuldade
);

    // Define estados
    parameter inicial               = 4'b0000;  // 0
    parameter preparacao            = 4'b0001;  // 1
    parameter proxima_mostra        = 4'b0010;  // 2
    parameter espera_jogada         = 4'b0011;  // 3
    parameter registra_jogada       = 4'b0100;  // 4
    parameter compara_jogada        = 4'b0101;  // 5
    parameter proxima_jogada        = 4'b0110;  // 6
    parameter foi_ultima_sequencia  = 4'b0111;  // 7
    parameter proxima_sequencia     = 4'b1000;  // 8
    parameter mostra_jogada         = 4'b1001;  // 9    
    parameter intervalo_mostra      = 4'b1010;  // A
    parameter inicia_sequencia      = 4'b1011;  // B
	parameter intervalo_rodada      = 4'b1100;  // C
    parameter final_timeout 	    = 4'b1101;  // D
    parameter final_acertou         = 4'b1110;  // E
    parameter final_errou           = 4'b1111;  // F
	 

    // Variaveis de estado
    reg [3:0] Eatual, Eprox;
	 reg Dificuldade;

    initial begin
        Eatual = inicial;
		  Dificuldade = 1'b0;
    end

    // Memoria de estado
    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    // Logica de proximo estado
    always @* begin
        case (Eatual)
            inicial:          Eprox <= iniciar ? preparacao : inicial;
            preparacao:       Eprox <= mostra_jogada;
            mostra_jogada:    Eprox <= meioM ? intervalo_mostra : mostra_jogada;
            intervalo_mostra: Eprox <= fimM ? proxima_mostra : intervalo_mostra;
            proxima_mostra:   Eprox <= enderecoIgualLimite ? inicia_sequencia : mostra_jogada;
            inicia_sequencia: Eprox <= espera_jogada;
            espera_jogada:    begin 
                if (jogada) begin
					Eprox <= registra_jogada;
				end else if (timeout) begin
					Eprox <= final_timeout;
				end else begin
					Eprox <= espera_jogada;
				end
            end													
            registra_jogada:  Eprox <= compara_jogada;
            compara_jogada:   begin 
                if (enderecoMenorLimite && botoesIgualMemoria) begin
					Eprox <= proxima_jogada;
				end else if (enderecoIgualLimite && botoesIgualMemoria) begin
					Eprox <= foi_ultima_sequencia ;
				end else begin
					Eprox <= final_errou;
				end
            end													
            proxima_jogada:         Eprox <= espera_jogada;
            foi_ultima_sequencia:   Eprox <= (fimL || (meioL && ~Dificuldade)) ? final_acertou : intervalo_rodada;
			intervalo_rodada:        Eprox <= meioM ? proxima_sequencia : intervalo_rodada;
            proxima_sequencia:      Eprox <= mostra_jogada;
            final_timeout:          Eprox <= iniciar ? preparacao : final_timeout;
            final_errou:            Eprox <= iniciar ? preparacao : final_errou;
            final_acertou:          Eprox <= iniciar ? preparacao : final_acertou;
            default:                Eprox <= inicial;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        zeraL     	<= (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
        zeraR     	<= (Eatual == inicial || Eatual == preparacao) ? 1'b1 : 1'b0;
        zeraE     	<= (Eatual == inicial || Eatual == preparacao || Eatual == proxima_sequencia || Eatual == inicia_sequencia) ? 1'b1 : 1'b0;
        registraR 	<= (Eatual == registra_jogada) ? 1'b1 : 1'b0;
        contaL    	<= (Eatual == proxima_sequencia) ? 1'b1 : 1'b0;
        contaE    	<= (Eatual == proxima_jogada || Eatual == proxima_mostra) ? 1'b1 : 1'b0;
        pronto    	<= (Eatual == final_acertou || Eatual == final_errou || Eatual == final_timeout) ? 1'b1 : 1'b0;
        acertou   	<= (Eatual == final_acertou) ? 1'b1 : 1'b0;
        errou     	<= (Eatual == final_errou) ? 1'b1 : 1'b0;
		contaT	   	<= (Eatual == espera_jogada) ? 1'b1 : 1'b0;
		zeraM       <= (Eatual == foi_ultima_sequencia || Eatual == preparacao || Eatual == proxima_mostra || Eatual == proxima_sequencia) ? 1'b1 : 1'b0;
        contaM      <= (Eatual == intervalo_rodada || Eatual == mostra_jogada || Eatual == intervalo_mostra) ? 1'b1 : 1'b0;
        fim_timeout <= (Eatual == final_timeout) ? 1'b1 : 1'b0;
        reset_random <= (Eatual == final_acertou || Eatual == final_errou || Eatual == final_timeout) ? 1'b1 : 1'b0;
        seletorMemoria <= (Eatual == preparacao) ? 1'b1 : 1'b0;
        if (Eatual == espera_jogada || Eatual == registra_jogada || Eatual == proxima_jogada 
		  || Eatual == compara_jogada || Eatual == foi_ultima_sequencia || Eatual == espera_jogada 
		  || Eatual == intervalo_rodada) begin
            seletor <= 2'b10;
        end else if (Eatual == mostra_jogada) begin
            seletor <= 2'b01;
        end else begin
            seletor <= 2'b00;
        end

        if (Eatual == preparacao) begin 
		    Dificuldade <= chaveDificuldade;
		end

        // Saida de depuracao (estado)
        case (Eatual)
            inicial:                db_estado <= 4'b0000;  // 0
            preparacao:             db_estado <= 4'b0001;  // 1
            proxima_mostra:         db_estado <= 4'b0010;  // 2
            espera_jogada:          db_estado <= 4'b0011;  // 3
            registra_jogada:        db_estado <= 4'b0100;  // 4
            compara_jogada:         db_estado <= 4'b0101;  // 5
            proxima_jogada:         db_estado <= 4'b0110;  // 6
            foi_ultima_sequencia:   db_estado <= 4'b0111;  // 7
            proxima_sequencia:      db_estado <= 4'b1000;  // 8
            mostra_jogada:          db_estado <= 4'b1001;  // 9
            intervalo_mostra:       db_estado <= 4'b1010;  // A
            inicia_sequencia:       db_estado <= 4'b1011;  // B
			   intervalo_rodada:        db_estado <= 4'b1100;  // C
            final_timeout:	 	      db_estado <= 4'b1101;  // D
            final_acertou:          db_estado <= 4'b1110;  // E
            final_errou:            db_estado <= 4'b1111;  // F
            default:                db_estado <= 4'b1001;  // 9 ERRO
        endcase
    end
	
	assign db_dificuldade = Dificuldade;

endmodule//------------------------------------------------------------------
// Arquivo   : circuito_exp5.v
// Projeto   : Experiencia 5 - Projeto de um Sistema Digital 
//------------------------------------------------------------------
// Descricao : Modulo principal da experiencia
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor            Descricao
//     18/01/2025  1.0     T5BB5            versao inicial
//------------------------------------------------------------------
//

module jogo_desafio_memoria (
    input clock,
    input reset,
    input jogar,
    input dificuldade,
    input [6:0] botoes,
    output [6:0] jogadas,
    output [3:0] estado,
    output [2:0] pontuacao,
    output pronto
);

wire [3:0] s_contagem, s_estado, s_limite;
wire [6:0] s_botoes, s_memoria;
wire [1:0] s_selMux;
wire s_fimE, s_fimL, s_botoes_igual_memoria,s_meioL, s_dificuldade, s_zeraE, s_zeraL, s_contaE, s_contaL;
wire s_zeraR, s_registraR, s_jogada, s_timeout, s_contaT, s_endereco_igual_limite, s_endereco_menor_limite;
wire s_zeraM, s_contaM, s_meioM, s_fimM, s_sel_memoria, s_reset_random;
wire [6:0] s_jogadas;

wire s_ganhou, s_perdeu, s_fim_timeout;
assign pontuacao = 2'b0;
assign estado = s_estado;
assign jogadas = s_jogadas;

unidade_controle controlUnit (
    .clock                  (clock),
    .reset                  (reset),
    .iniciar                (jogar),
    .jogada                 (s_jogada),
	.timeout                (s_timeout),
    .botoesIgualMemoria     (s_botoes_igual_memoria),
    .fimE                   (s_fimE),
    .fimL                   (s_fimL),
	.meioL					(s_meioL),
    .enderecoIgualLimite    (s_endereco_igual_limite),
    .enderecoMenorLimite    (s_endereco_menor_limite),
    .zeraE                  (s_zeraE),
    .contaE                 (s_contaE),
    .zeraL                  (s_zeraL),
    .contaL                 (s_contaL),
    .zeraR                  (s_zeraR),
    .registraR              (s_registraR),
    .acertou                (s_ganhou),
    .errou                  (s_perdeu),
    .pronto                 (pronto),
    .fim_timeout            (s_fim_timeout),
    .db_estado              (s_estado),
	.contaT                 (s_contaT),
	.db_dificuldade 		(s_dificuldade),
	.chaveDificuldade		(dificuldade),
    .seletor                (s_selMux),
    .zeraM                  (s_zeraM),
    .contaM                 (s_contaM),
    .meioM                  (s_meioM),
    .seletorMemoria			(s_sel_memoria),
    .reset_random           (s_reset_random),
    .fimM                   (s_fimM)
);

fluxo_dados fluxo_dados (
    .clock                  (clock),
    .zeraE                  (s_zeraE),
    .contaE                 (s_contaE),
    .zeraL                  (s_zeraL),
    .contaL                 (s_contaL),
    .zeraR                  (s_zeraR),
    .registraR              (s_registraR),
    .botoes                 (botoes),
    .selecionaMemoria		(s_sel_memoria),
    .reset_random           (s_reset_random),
    .contaT                 (s_contaT),
    .botoesIgualMemoria     (s_botoes_igual_memoria),
    .fimE                   (s_fimE),
    .fimL                   (s_fimL),
    .meioL 					(s_meioL),
    .endecoIgualLimite      (s_endereco_igual_limite),
    .endecoMenorLimite      (s_endereco_menor_limite),
    .jogada_feita           (s_jogada),
    .db_limite              (s_limite),
    .db_contagem            (s_contagem),
    .db_memoria             (s_memoria),
    .db_jogada              (s_botoes),
	.timeout                (s_timeout),
    .leds                   (s_jogadas),	
    .seletor                (s_selMux),
    .zeraM                  (s_zeraM),
    .contaM                 (s_contaM),
    .meioM                  (s_meioM),
    .fimM                   (s_fimM)
);

endmodule// ---------------------------------------------------------------------
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
// ---------------------------------------------------------------------
// BitBakery Serial Transmitter - 8E1 Format
// ---------------------------------------------------------------------
// Description : Transmitter module for BitBakery game using 8E1 serial format
// Trasnmitter sends 4 packets of data indefinitely
// ---------------------------------------------------------------------

module bitbakery_serial_tx (
    input clock,
    input reset,
    input [7:0] D0,
    input [7:0] D1,
    input [7:0] D2,
    input [7:0] D3,
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
    .D3             (D3           ),
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
