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

endmodule