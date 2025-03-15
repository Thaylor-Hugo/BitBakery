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
    input clock,
    input reset,
    input iniciar,
    input dificuldade,
    input [1:0] minigame,
    input [6:0] botoes,
    output [1:0] minigame_out,
    output [2:0] leds_out,
    output [3:0] estado_out,
    output [6:0] jogada_out,
    output [2:0] pontuacao_out
);

parameter inicial = 2'b00;
parameter preparacao = 2'b01;
parameter execucao = 2'b10;
parameter fim = 2'b11;

wire s_pronto_0, s_pronto_1, s_pronto_2, s_pronto;
wire [2:0] s_leds_0, s_leds_1, s_leds_2;
wire [3:0] s_estado_0, s_estado_1, s_estado_2, s_estado_inicial;
wire [6:0] s_jogada_0, s_jogada_1, s_jogada_2;
wire [2:0] s_pontuacao_0, s_pontuacao_1, s_pontuacao_2;

reg [1:0] MiniGame, Eatual, Eprox;
reg Dificuldade, s_iniciar;

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
        preparacao: Eprox = (MiniGame != 2'b11)? execucao : preparacao;
        execucao: Eprox = s_pronto ? fim : execucao;
        fim: Eprox = iniciar ? preparacao : fim; 
        default: Eprox = inicial;
    endcase
end

// Lógica de saída
always @* begin
    s_iniciar <= (Eatual == preparacao)? 1'b1 : 1'b0;
    Dificuldade <= (Eatual == preparacao)? dificuldade : Dificuldade;
    MiniGame <= (Eatual == preparacao)? minigame : MiniGame;
end

mux_out saidas (
    .minigame       (MiniGame),
    .leds_0         (s_leds_0),
    .estado_0       (s_estado_0),
    .jogada_0       (s_jogada_0),
    .pronto_0       (s_pronto_0),
    .pontuacao_0    (s_pontuacao_0),
    .leds_1         (s_leds_1),
    .estado_1       (s_estado_1),
    .jogada_1       (s_jogada_1),
    .pronto_1       (s_pronto_1),
    .pontuacao_1    (s_pontuacao_1),
    .leds_2         (s_leds_2),
    .estado_2       (s_estado_2),
    .jogada_2       (s_jogada_2),
    .pronto_2       (s_pronto_2),
    .pontuacao_2    (s_pontuacao_2),
    .estado_inicial (s_estado_inicial),
    .leds_out       (leds_out),
    .estado_out     (estado_out),
    .jogada_out     (jogada_out),
    .pronto_out     (s_pronto),
    .pontuacao_out  (pontuacao_out)
);

jogo_desafio_memoria game0 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_0),
    .jogadas        (s_jogada_0),
    .leds           (s_leds_0),
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
    .leds           (s_leds_1),
    .pontuacao      (s_pontuacao_1),
    .pronto         (s_pronto_1)
);

clothesgame game2 (
    .clock          (clock),
    .reset          (reset),
    .jogar          (s_iniciar),
    .dificuldade    (Dificuldade),
    .botoes         (botoes),
    .estado         (s_estado_2),
    .jogadas        (s_jogada_2),
    .leds           (s_leds_2),
    .pontuacao      (s_pontuacao_2),
    .pronto         (s_pronto_2)
);

assign s_estado_inicial = Eatual;
assign minigame_out = MiniGame;

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
/* ------------------------------------------------------------------------
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
/* ----------------------------------------------------------------
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

module mux2x1 (
    input [6:0] D0,
    input [6:0] D1,
    input SEL,
    output reg [6:0] OUT
);

always @(*) begin
    case (SEL)
        1'b0:    OUT = D0;
        1'b1:    OUT = D1;
        default: OUT = 4'b0; // saida em 1
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
    input [2:0] leds_0,
    input [3:0] estado_0,
    input [6:0] jogada_0,
    input [2:0] pontuacao_0,
    input pronto_0,
    input [2:0] leds_1,
    input [3:0] estado_1,
    input [6:0] jogada_1,
    input [2:0] pontuacao_1,
    input pronto_1,
    input [2:0] leds_2,
    input [3:0] estado_2,
    input [6:0] jogada_2,
    input [2:0] pontuacao_2,
    input pronto_2,
    input [3:0] estado_inicial,
    output reg [2:0] leds_out,
    output reg [3:0] estado_out,
    output reg [6:0] jogada_out,
    output reg [2:0] pontuacao_out,
    output reg pronto_out
);

always @(*) begin
    case (minigame)
        2'b00: begin
            leds_out = leds_0;
            estado_out = estado_0;
            jogada_out = jogada_0;
            pontuacao_out = pontuacao_0;
            pronto_out = pronto_0;
        end
        2'b01: begin
            leds_out = leds_1;
            estado_out = estado_1;
            jogada_out = jogada_1;
            pontuacao_out = pontuacao_1;
            pronto_out = pronto_1;
        end
        2'b10: begin
            leds_out = leds_2;
            estado_out = estado_2;
            jogada_out = jogada_2;
            pontuacao_out = pontuacao_2;
            pronto_out = pronto_2;
        end
        2'b11: begin
            leds_out = 3'b0;
            jogada_out = 7'b0;
            estado_out = estado_inicial;
            pontuacao_out = 7'b0;
            pronto_out = 1'b0;
        end
        default: begin
            leds_out = 3'b0;
            estado_out = 4'b0;
            jogada_out = 7'b0;
            pontuacao_out = 7'b0;
            pronto_out = 1'b0;
        end
    endcase
end
    
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

endmodule//------------------------------------------------------------------
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
            7'b0000000: data_out = 7'b0000001; //1
            7'b0000001: data_out = 7'b0000100; //2
            7'b0000010: data_out = 7'b0000010; //3
            7'b0000011: data_out = 7'b0001000; //4
            7'b0000100: data_out = 7'b0000001; //5
            7'b0000101: data_out = 7'b0000100; //6
            7'b0000110: data_out = 7'b0000010; //7
            7'b0000111: data_out = 7'b0001000; //8
            7'b0001000: data_out = 7'b0000001; //9
            7'b0001001: data_out = 7'b0000001; //10
            7'b0001010: data_out = 7'b0001000; //11
            7'b0001011: data_out = 7'b0001000; //12
            7'b0001100: data_out = 7'b0000010; //13
            7'b0001101: data_out = 7'b0000100; //14
            7'b0001110: data_out = 7'b0000100; //15
            7'b0001111: data_out = 7'b0000001; //16
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
            7'b0000000: data_out = 7'b0000001; //1
            7'b0000001: data_out = 7'b0000010; //2
            7'b0000010: data_out = 7'b0000100; //3
            7'b0000011: data_out = 7'b0001000; //4
            7'b0000100: data_out = 7'b0000100; //5
            7'b0000101: data_out = 7'b0000010; //6
            7'b0000110: data_out = 7'b0000001; //7
            7'b0000111: data_out = 7'b0000001; //8
            7'b0001000: data_out = 7'b0000010; //9
            7'b0001001: data_out = 7'b0000010; //10
            7'b0001010: data_out = 7'b0000100; //11
            7'b0001011: data_out = 7'b0000100; //12
            7'b0001100: data_out = 7'b0001000; //13
            7'b0001101: data_out = 7'b0001000; //14
            7'b0001110: data_out = 7'b0000001; //15
            7'b0001111: data_out = 7'b0000100; //16
        endcase
    end
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
wire [6:0] s_data, s_data_2, s_mem_out;
wire [6:0] s_reg;
wire signal = buttons[0] | buttons[1] | buttons[2] | buttons[3] | buttons[4] | buttons[5] | buttons[6];

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

sync_rom_16x4 rom_1 (
    .clock      (clock),
    .address    (s_address),
    .data_out   (s_data)
);

sync_rom_16x4_mem2 rom_2 (
    .clock      (clock),
    .address    (s_address),
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
    .A    (s_mem_out),
    .B    (s_reg),
    .ALBo (    ),
    .AGBo (    ),
    .AEBo (correct_play)
);

// General Timers
contador_m  #(.M(1000),.N(16)) show_counter (
    .clock      (clock),   
    .zera_as    (clear_show_counter),
    .zera_s     (1'b0),
    .conta	    (enable_show_counter),
    .Q          (),
    .fim        (end_show),
    .meio       (half_show)
);

contador_m  #(.M(4000), .N(16)) timeout_counter (
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
    .D1     (s_mem_out),
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
parameter end_state     = 4'b1111; // F

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
        preparation:    next_state <= show_play;
        show_play:      next_state <= half_show ? show_interval : show_play;
        show_interval:  next_state <= end_show ? next_show : show_interval;
        next_show:      next_state <= end_mem_counter ? initiate_play : show_play;
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
    clear_show_counter <= (current_state == preparation) ? 1'b1 : 1'b0;
    enable_show_counter <= (current_state == show_interval || current_state == show_play) ? 1'b1 : 1'b0;
    enable_timeout_counter <= (current_state == wait_play) ? 1'b1 : 1'b0;
    clear_points_counter <= (current_state == preparation) ? 1'b1 : 1'b0;
    enable_points_counter <= (correct_play && (current_state == next_play)) ? 1'b1 : 1'b0;
    finished <= (current_state == end_state) ? 1'b1 : 1'b0;
    state <= current_state;

    if (current_state == wait_play || current_state == register_play
        || current_state == compare_play || current_state == next_play)
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
    output [2:0] leds,
    output [2:0] pontuacao,
    output pronto
);

wire [1:0] s_out_sel;
wire [3:0] s_estado;
wire s_clear_reg, s_enable_reg, s_clear_mem_counter, s_enable_mem_counter, s_clear_show_counter, s_enable_show_counter, s_enable_timeout_counter, s_clear_points_counter, s_enable_points_counter, s_end_mem_counter, s_correct_play, s_has_play, s_end_show, s_half_show, s_timeout, s_pronto;

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
    .finished               (pronto),
    .state                  (s_estado)
);

// TODO: Implementar lógica de leds
assign leds = (s_estado == 4'b1111) ? 3'b100 : (s_estado == 4'b0110)? 3'b010 : 3'b001;
assign estado = s_estado;

endmodule

module clothesgame (
    input clock,
    input reset,
    input jogar,
    input dificuldade,
    input [6:0] botoes,
    output [6:0] jogadas,
    output [3:0] estado,
    output [2:0] leds,
    output [2:0] pontuacao,
    output pronto
);
    assign jogadas = 7'b0;
    assign pontuacao = 3'b0;
    assign pronto = 1'b1;
    assign estado = 4'b0;
    assign leds = 3'b101;

endmodule
//------------------------------------------------------------------
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
    input [3:0] botoes,
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
    output db_tem_jogada,
    output [3:0] db_limite,
    output [3:0] db_contagem,
    output [3:0] db_memoria,
    output [3:0] db_jogada,
    output [3:0] leds,
	output timeout

);
    wire [3:0] s_endereco, s_dado, s_dado2, s_saida_memorias, s_botoes, s_limite, s_leds;  // sinal interno para interligacao dos componentes
    wire s_jogada;
    wire sinal = botoes[0] | botoes[1] | botoes[2] | botoes[3];


    // multiplexador 3x1
    mux3x1 mux (

        .D0      (4'b0),
        .D1      (s_saida_memorias),
        .D2      (botoes),
        .SEL     (seletor),
        .OUT     (s_leds)

    );
	 
	 mux2x1 mux_memorias (

        .D0      (s_dado),
        .D1      (s_dado2),
        .SEL     (selecionaMemoria),
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
    contador_m  #(.M(1000),.N(16)) contadorM (
       .clock     (clock),   
       .zera_as   (zeraM),
       .zera_s    (1'b0),
       .conta	  (contaM),
       .Q         (),
       .fim       (fimM),
       .meio      (meioM)
    );
	 
	 // contador_m
    contador_m  #(.M(4000), .N(16)) contador_timeout (
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
    comparador_85 comparador (
        .A    (s_saida_memorias),
        .B    (s_botoes),
        .ALBi (1'b0),
        .AGBi (1'b0),
        .AEBi (1'b1),
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
    assign db_tem_jogada = sinal;
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
	 input chaveMemoria,
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
	 output  seletorMemoria,
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
	 reg Dificuldade, Memoria;

    initial begin
        Eatual = inicial;
		  Dificuldade = 1'b0;
		  Memoria = 1'b0;
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
			 Memoria <= chaveMemoria;
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
	assign seletorMemoria = Memoria;

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
    output [2:0] leds,
    output [2:0] pontuacao,
    output pronto
);

wire [3:0] s_botoes, s_memoria, s_contagem, s_estado, s_limite;
wire [1:0] s_selMux;
wire s_fimE, s_fimL, s_botoes_igual_memoria,s_meioL, s_dificuldade, s_zeraE, s_zeraL, s_contaE, s_contaL;
wire s_zeraR, s_registraR, s_jogada, s_timeout, s_contaT, s_endereco_igual_limite, s_endereco_menor_limite;
wire s_zeraM, s_contaM, s_meioM, s_fimM, s_sel_memoria;
wire [3:0] s_jogadas;

wire s_ganhou, s_perdeu, s_fim_timeout;
assign pontuacao = 2'b0;
assign leds = {s_ganhou, s_fim_timeout, s_perdeu};
assign estado = s_estado;
assign jogadas = {3'b0, s_jogadas[3:0]};

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
    .chaveMemoria     		(1'b0),
    .seletorMemoria			(s_sel_memoria),
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
    .botoes                 (botoes[3:0]),
    .selecionaMemoria		(s_sel_memoria),
    .contaT                 (s_contaT),
    .botoesIgualMemoria     (s_botoes_igual_memoria),
    .fimE                   (s_fimE),
    .fimL                   (s_fimL),
    .meioL 					(s_meioL),
    .endecoIgualLimite      (s_endereco_igual_limite),
    .endecoMenorLimite      (s_endereco_menor_limite),
    .jogada_feita           (s_jogada),
    .db_tem_jogada          (db_tem_jogada),
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

endmodule