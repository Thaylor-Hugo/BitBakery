module xor_paridade (
    input wire [7:0] dados,
    output wire paridade
);
    assign paridade = ^dados;
endmodule