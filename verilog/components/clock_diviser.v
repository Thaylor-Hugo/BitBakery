
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
    if (counter == 25000000) begin
        counter <= 0;
        clock_divised <= ~clock_divised;
    end else begin
        counter <= counter + 1;
    end
end
    
endmodule
