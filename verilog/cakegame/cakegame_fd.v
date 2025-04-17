
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
