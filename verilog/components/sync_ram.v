
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
