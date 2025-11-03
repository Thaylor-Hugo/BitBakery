module xor_paridade (
    input wire [6:0] dados,
    output wire paridade
);
    assign paridade = ^dados;
endmodule