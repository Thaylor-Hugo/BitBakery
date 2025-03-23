//------------------------------------------------------------------
// Arquivo   : sync_cake_rom.v
// Projeto   : BitBakery 
//------------------------------------------------------------------
// Descricao : ROM sincrona 16x4 (conteúdo pre-programado)
//              Memoria para diferentes bolos
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//     22/03/2025  1.0     T5BB5             versao final
//------------------------------------------------------------------
//
module rom (clock, address, data_out);
    input            clock;
    input      [2:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            3'b000: data_out = 7'b0000001;
            3'b001: data_out = 7'b0000010;
            3'b010: data_out = 7'b0000100;
            3'b011: data_out = 7'b0001000;
            3'b100: data_out = 7'b0010000;
            3'b101: data_out = 7'b0100000;
            3'b110: data_out = 7'b1000000;
        endcase
    end
endmodule

