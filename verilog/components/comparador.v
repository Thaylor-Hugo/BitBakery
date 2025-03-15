
module comparador (
    input [6:0] A,
    input [6:0] B,
    output ALBo,
    output AGBo,
    output AEBo
);

assign ALBo = (A < B);
assign AGBo = (A > B);
assign AEBo = (A == B);

endmodule