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
            4'b0000: data_out = 7'b0001000; //1
            4'b0001: data_out = 7'b0010000; //2
            4'b0010: data_out = 7'b0100000; //3
            4'b0011: data_out = 7'b0000100; //4
            4'b0100: data_out = 7'b0000001; //5
            4'b0101: data_out = 7'b0000001; //6
            4'b0110: data_out = 7'b0001000; //7
            4'b0111: data_out = 7'b0000010; //8
            4'b1000: data_out = 7'b0100000; //9
            4'b1001: data_out = 7'b0000001; //10
            4'b1010: data_out = 7'b0000100; //11
            4'b1011: data_out = 7'b0000010; //12
            4'b1100: data_out = 7'b0001000; //13
            4'b1101: data_out = 7'b0100000; //14
            4'b1110: data_out = 7'b0010000; //15
            4'b1111: data_out = 7'b0010000; //16
        endcase
    end
endmodule

