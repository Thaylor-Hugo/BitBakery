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