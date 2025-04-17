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
module rom_easy (clock, address, data_out);
    input            clock;
    input      [1:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            2'b00: data_out = 7'b0000001;
            2'b01: data_out = 7'b0000010;
            2'b10: data_out = 7'b0000100;
            2'b11: data_out = 7'b0001000;
        endcase
    end
endmodule

