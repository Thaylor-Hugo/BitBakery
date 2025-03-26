
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
wire [N-1:0] temp;

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
assign temp = lfsr[N-1:0] ^ lfsr[LFSR_SIZE-1:LFSR_SIZE-N];
assign address = (N==3) ? ((temp == 3'b111) ? 3'b000 : temp) : temp;

endmodule
