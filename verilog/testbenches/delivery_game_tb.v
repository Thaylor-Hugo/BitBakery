`timescale 1us/1us

module delivery_game_tb;

// Testbench signals
reg clock;
reg reset;
reg jogar;
reg [6:0] botoes;
reg echo;
wire [3:0] estado;
wire [2:0] pontuacao;
wire pronto;
wire pwm;
wire trigger;
wire [3:0] db_player_position;
wire [3:0] db_new_obstacle;
wire [3:0] db_new_objective;

// Clock parameters
parameter CLOCK_PERIOD = 1000; // 1ms = 1kHz clock

// Distance simulation parameters
integer distance; // in cm
integer echo_time; // in us
integer game_time; // in ms

// DUT instantiation
delivery_game dut (
    .clock (clock),
    .reset (reset),
    .jogar (jogar),
    .botoes (botoes),
    .echo (echo),
    .estado (estado),
    .pontuacao (pontuacao),
    .pronto (pronto),
    .pwm (pwm),
    .trigger (trigger),
    .db_player_position (db_player_position),
    .db_new_obstacle (db_new_obstacle),
    .db_new_objective (db_new_objective)
);

// Clock generation
always #(CLOCK_PERIOD/2) clock = ~clock;

// Task to simulate ultrasonic sensor echo based on distance
// Distance in cm, echo pulse width = 58us per cm
task simulate_echo;
    input integer dist_cm;
    begin
        echo_time = dist_cm * 58; // 58us per cm
        @(posedge trigger);
        #150; // Ultrasonic sensor delay
        echo = 1'b1;
        #echo_time;
        echo = 1'b0;
    end
endtask

// Task to press a button for one clock cycle
task press_button;
    input [2:0] button_num;
    begin
        @(negedge clock);
        botoes[button_num] = 1'b1;
        @(negedge clock);
        botoes[button_num] = 1'b0;
    end
endtask

// Task to move player to avoid obstacles
// Player position is one-hot: 4'b1000=pos0, 4'b0100=pos1, 4'b0010=pos2, 4'b0001=pos3
// Obstacle position is also one-hot encoded
task avoid_obstacle;
    input [3:0] obstacle_pos;
    input [3:0] current_pos;
    begin
        // If obstacle at position 0 (bit 3) and player at position 0
        if (obstacle_pos[3] && current_pos[3]) begin
            press_button(1); // Move right
        end
        // If obstacle at position 1 (bit 2) and player at position 1
        else if (obstacle_pos[2] && current_pos[2]) begin
            if (current_pos != 4'b1000) // Not at leftmost
                press_button(0); // Move left
            else
                press_button(1); // Move right
        end
        // If obstacle at position 2 (bit 1) and player at position 2
        else if (obstacle_pos[1] && current_pos[1]) begin
            if (current_pos != 4'b0001) // Not at rightmost
                press_button(1); // Move right
            else
                press_button(0); // Move left
        end
        // If obstacle at position 3 (bit 0) and player at position 3
        else if (obstacle_pos[0] && current_pos[0]) begin
            press_button(0); // Move left
        end
    end
endtask

// Echo simulation - runs continuously
always begin
    if (!reset && !pronto && game_time < 30000) begin
        simulate_echo(distance);
    end
    else begin
        #(CLOCK_PERIOD);
    end
end

// Main test process
initial begin
    // Initialize signals
    clock = 1'b0;
    reset = 1'b0;
    jogar = 1'b0;
    botoes = 7'b0000000;
    echo = 1'b0;
    distance = 50; // Start at 50cm
    game_time = 0;
    
    // Display header
    $display("====================================");
    $display("Delivery Game Testbench");
    $display("====================================");
    $display("Time(ms) | Dist(cm) | Estado | Pos  | Obs | Obj | Score | Pronto");
    $display("-----------------------------------------------------------------------");
    
    // Reset pulse
    @(negedge clock);
    reset = 1'b1;
    #(CLOCK_PERIOD);
    reset = 1'b0;
    #(CLOCK_PERIOD * 2);
    
    // Start game
    @(negedge clock);
    jogar = 1'b1;
    #(CLOCK_PERIOD);
    jogar = 1'b0;
    #(CLOCK_PERIOD * 2);
    
    // Game loop - run for approximately 30 seconds or until game over
    while (!pronto && game_time < 30000) begin
        // Update time
        #(CLOCK_PERIOD);
        game_time = game_time + 1;
        
        // Vary distance over time to simulate player movement
        if (game_time % 100 == 0) begin // Update every 100ms
            if (game_time < 5000) begin
                distance = 50; // Far (slow) - first 5 seconds
            end
            else if (game_time < 10000) begin
                distance = 30; // Medium - next 5 seconds
            end
            else if (game_time < 15000) begin
                distance = 15; // Close (fast) - next 5 seconds
            end
            else if (game_time < 20000) begin
                distance = 40; // Medium-far - next 5 seconds
            end
            else if (game_time < 25000) begin
                distance = 10; // Very close (very fast) - next 5 seconds
            end
            else begin
                distance = 25; // Medium - last 5 seconds
            end
        end
        
        // Check for obstacles and try to avoid them every 200ms
        if (game_time % 200 == 0 && db_new_obstacle != 4'b0000) begin
            avoid_obstacle(db_new_obstacle, db_player_position);
        end
        
        // Sometimes try to collect objectives every 200ms
        if (game_time % 200 == 0 && db_new_objective != 4'b0000 && ($random % 3 == 0)) begin
            // 33% chance to try to move to objective
            // Position 0 (bit 3)
            if (db_new_objective[3] && !db_player_position[3])
                press_button(0); // Move left towards position 0
            // Position 1 (bit 2)
            else if (db_new_objective[2] && !db_player_position[2]) begin
                if (db_player_position[3]) // Currently at pos 0
                    press_button(1); // Move right
                else
                    press_button(0); // Move left
            end
            // Position 2 (bit 1)
            else if (db_new_objective[1] && !db_player_position[1]) begin
                if (db_player_position[0]) // Currently at pos 3
                    press_button(0); // Move left
                else
                    press_button(1); // Move right
            end
            // Position 3 (bit 0)
            else if (db_new_objective[0] && !db_player_position[0])
                press_button(1); // Move right towards position 3
        end
        
        // Display status every second
        if (game_time % 1000 == 0) begin
            $display("%7d  |   %2d     |   %1h    | %4b| %4b| %4b|   %1d   | %1b",
                     game_time, distance, estado, db_player_position,
                     db_new_obstacle, db_new_objective, pontuacao, pronto);
        end
    end
    
    // Final status
    #(CLOCK_PERIOD * 10);
    $display("-----------------------------------------------------------------------");
    $display("Game ended at %0d ms", game_time);
    $display("Final score: %0d", pontuacao);
    $display("Game over (pronto): %0b", pronto);
    $display("Final estado: %0h", estado);
    $display("Final position: %4b", db_player_position);
    $display("====================================");
    
    $finish;
end

// Watchdog timer - force end after 35 seconds
initial begin
    #(CLOCK_PERIOD * 35000);
    $display("ERROR: Testbench timeout after 35 seconds");
    $finish;
end

endmodule
