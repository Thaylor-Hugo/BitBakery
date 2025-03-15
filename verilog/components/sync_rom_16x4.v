//------------------------------------------------------------------
// Arquivo   : sync_rom_16x4.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle 
//------------------------------------------------------------------
// Descricao : ROM sincrona 16x4 (conteúdo pre-programado)
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//
module sync_rom_16x4 (clock, address, data_out);
    input            clock;
    input      [3:0] address;
    output reg [6:0] data_out;

    always @ (posedge clock)
    begin
        case (address)
            7'b0000000: data_out = 7'b0000001; //1
            7'b0000001: data_out = 7'b0000010; //2
            7'b0000010: data_out = 7'b0000100; //3
            7'b0000011: data_out = 7'b0001000; //4
            7'b0000100: data_out = 7'b0000100; //5
            7'b0000101: data_out = 7'b0000010; //6
            7'b0000110: data_out = 7'b0000001; //7
            7'b0000111: data_out = 7'b0000001; //8
            7'b0001000: data_out = 7'b0000010; //9
            7'b0001001: data_out = 7'b0000010; //10
            7'b0001010: data_out = 7'b0000100; //11
            7'b0001011: data_out = 7'b0000100; //12
            7'b0001100: data_out = 7'b0001000; //13
            7'b0001101: data_out = 7'b0001000; //14
            7'b0001110: data_out = 7'b0000001; //15
            7'b0001111: data_out = 7'b0000100; //16
        endcase
    end
endmodule

