
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
