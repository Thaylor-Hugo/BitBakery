// ---------------------------------------------------------------------
// Map Counter Testbench
// ---------------------------------------------------------------------
// Description : Testbench for map_counter module
//               Tests base_speed increment every 30s and velocity changes
// ---------------------------------------------------------------------

`timescale 1us/1us  // Using microseconds for proper clock resolution

module map_counter_tb;

// Declaracao de sinais
reg clock;
reg reset;
reg count_map;
reg [1:0] velocity;
wire move_map;

// Contador para controle de tempo
integer time_counter;
integer velocity_change_counter;
integer base_speed_increments;

// Configuracao do clock (1kHz = 1ms period = 1000us)
parameter CLOCK_PERIOD = 1000; // 1000us = 1ms period for 1kHz clock

// Instanciacao do DUT (Device Under Test)
map_counter dut (
    .clock      (clock),
    .reset      (reset),
    .count_map  (count_map),
    .velocity   (velocity),
    .move_map   (move_map)
);

// Gerador de clock (1kHz)
always #(CLOCK_PERIOD/2) clock = ~clock;

// Monitor de move_map (check any transition, not just posedge)
always @(move_map) begin
    if (!reset && count_map) begin
        $display("[%0t us] MOVE_MAP = %b | velocity=%0d | base_speed=%0d", 
                 $time, move_map, velocity, dut.s_base_velocity);
    end
end

// Monitor all timer fim signals
always @(dut.s_move_map_800 or dut.s_move_map_700 or dut.s_move_map_600 or 
         dut.s_move_map_500 or dut.s_move_map_400 or dut.s_move_map_300 or dut.s_move_map_200) begin
    if (!reset && count_map) begin
        $display("[%0t us] Timers: 800=%b 700=%b 600=%b 500=%b 400=%b 300=%b 200=%b", 
                 $time, dut.s_move_map_800, dut.s_move_map_700, dut.s_move_map_600, 
                 dut.s_move_map_500, dut.s_move_map_400, dut.s_move_map_300, dut.s_move_map_200);
    end
end

// Monitor base_velocity changes
always @(dut.s_base_velocity) begin
    if (!reset) begin
        $display("[%0t us] *** BASE_VELOCITY changed to %0d ***", $time, dut.s_base_velocity);
    end
end

// Monitor increment_velocity pulses
always @(posedge dut.s_increment_velocity) begin
    if (!reset) begin
        $display("[%0t us] +++ INCREMENT_VELOCITY pulse! +++", $time);
    end
end

// Processo principal de teste
initial begin
    $display("==============================================================");
    $display("Inicio da simulacao - Map Counter Testbench");
    $display("==============================================================");
    $display("Clock: 1kHz (1ms = 1000us period)");
    $display("Base speed increment: every 30,000ms (30s)");
    $display("Velocity change: every 5,000ms (5s)");
    $display("==============================================================\n");
    
    // Condicoes iniciais
    clock = 0;
    reset = 1;
    count_map = 0;
    velocity = 2'b00;
    time_counter = 0;
    velocity_change_counter = 0;
    base_speed_increments = 0;
    
    // Reset
    #(10*CLOCK_PERIOD);
    reset = 0;
    #(10*CLOCK_PERIOD);
    
    // Ativar count_map (sempre ativo apos reset)
    count_map = 1;
    $display("[%0t us] count_map activated, starting test...\n", $time);
    
    // Loop de teste: continua ate base_speed chegar ao max (4 incrementos = nivel 3)
    // e velocity estar no max (2'b11)
    while (dut.s_base_velocity < 2'b11 || velocity != 2'b11) begin
        // Periodic status every 1 second (1000ms = 1,000,000us)
        if (time_counter > 0 && (time_counter % 1000 == 0)) begin
            $display("[%0.1f ms] Status: velocity=%0d, base_vel=%0d, move_map=%b, timer_800=%b", 
                     $time/1000.0, velocity, dut.s_base_velocity, move_map, dut.s_move_map_800);
        end
        
        // A cada 5 segundos (5000ms = 5,000,000us), incrementar velocity
        if (time_counter > 0 && (time_counter % 5000 == 0)) begin
            if (velocity < 2'b11) begin
                velocity = velocity + 1;
                velocity_change_counter = velocity_change_counter + 1;
                $display("[%0.1f ms] >>> Velocity changed to %0d (change #%0d)", 
                         $time/1000.0, velocity, velocity_change_counter);
            end else begin
                $display("[%0.1f ms] >>> Velocity already at MAX (3)", $time/1000.0);
            end
        end
        
        // Track base_speed changes (don't predict, just observe)
        if (time_counter > 0 && (time_counter % 30000 == 0)) begin
            $display("[%0.1f ms] === 30 second mark - base_velocity should have incremented ===", $time/1000.0);
            
            // Reset velocity para 00 apos incremento de base_speed
            if (dut.s_base_velocity < 2'b11) begin
                velocity = 2'b00;
                velocity_change_counter = 0;
                $display("[%0.1f ms] >>> Velocity reset to 0 (starting new cycle)", $time/1000.0);
            end
        end
        
        #CLOCK_PERIOD;
        time_counter = time_counter + 1;
        
        // Safety: limitar simulacao a 150 segundos
        if (time_counter >= 150000) begin
            $display("\n[%0.1f ms] WARNING: Safety timeout reached (150s)", $time/1000.0);
            $stop;
        end
    end
    
    // Aguardar mais alguns ciclos com velocity no max e base_speed no max
    $display("\n[%0.1f ms] Final state reached: velocity=MAX, base_speed=MAX", $time/1000.0);
    $display("[%0.1f ms] Running for 10 more seconds to observe behavior...", $time/1000.0);
    #(10000*CLOCK_PERIOD);
    
    // Resumo final
    $display("\n==============================================================");
    $display("Fim da simulacao");
    $display("==============================================================");
    $display("Total simulation time: %0.1f ms (%0.1f seconds)", $time/1000.0, $time/1000000.0);
    $display("Final base_velocity: %0d", dut.s_base_velocity);
    $display("Velocity changes: %0d", velocity_change_counter);
    $display("==============================================================");
    $stop;
end

// Dump de ondas para visualizacao (GTKWave)
initial begin
    $dumpfile("map_counter_tb.vcd");
    $dumpvars(0, map_counter_tb);
end

endmodule
