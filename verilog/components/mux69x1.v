/*------------------------------------------------------------------------
 * Arquivo   : mux69x1.v
 * Projeto   : BitBakery - Delivery Game
 *------------------------------------------------------------------------
 * Descricao : multiplexador 69x1 para transmissão serial
 *             Transmite: 1 start + 3 dados + 64 map bytes + 1 end = 69 bytes
 *------------------------------------------------------------------------
 */

module mux69x1 (
    input [7:0] start_byte,     // 0xFF
    input [7:0] D0,             // Data byte 0
    input [7:0] D1,             // Data byte 1
    input [7:0] D2,             // Data byte 2
    input [511:0] map_data,     // 128 rows * 4 bits = 512 bits = 64 bytes
    input [7:0] end_byte,       // 0xFE
    input [6:0] SEL,            // 7 bits to select 0-68
    output reg [7:0] OUT
);

always @(*) begin
    case (SEL)
        7'd0:  OUT = start_byte;
        7'd1:  OUT = D0;
        7'd2:  OUT = D1;
        7'd3:  OUT = D2;
        // Map data bytes (64 bytes for 512 bits)
        7'd4:  OUT = map_data[7:0];
        7'd5:  OUT = map_data[15:8];
        7'd6:  OUT = map_data[23:16];
        7'd7:  OUT = map_data[31:24];
        7'd8:  OUT = map_data[39:32];
        7'd9:  OUT = map_data[47:40];
        7'd10: OUT = map_data[55:48];
        7'd11: OUT = map_data[63:56];
        7'd12: OUT = map_data[71:64];
        7'd13: OUT = map_data[79:72];
        7'd14: OUT = map_data[87:80];
        7'd15: OUT = map_data[95:88];
        7'd16: OUT = map_data[103:96];
        7'd17: OUT = map_data[111:104];
        7'd18: OUT = map_data[119:112];
        7'd19: OUT = map_data[127:120];
        7'd20: OUT = map_data[135:128];
        7'd21: OUT = map_data[143:136];
        7'd22: OUT = map_data[151:144];
        7'd23: OUT = map_data[159:152];
        7'd24: OUT = map_data[167:160];
        7'd25: OUT = map_data[175:168];
        7'd26: OUT = map_data[183:176];
        7'd27: OUT = map_data[191:184];
        7'd28: OUT = map_data[199:192];
        7'd29: OUT = map_data[207:200];
        7'd30: OUT = map_data[215:208];
        7'd31: OUT = map_data[223:216];
        7'd32: OUT = map_data[231:224];
        7'd33: OUT = map_data[239:232];
        7'd34: OUT = map_data[247:240];
        7'd35: OUT = map_data[255:248];
        7'd36: OUT = map_data[263:256];
        7'd37: OUT = map_data[271:264];
        7'd38: OUT = map_data[279:272];
        7'd39: OUT = map_data[287:280];
        7'd40: OUT = map_data[295:288];
        7'd41: OUT = map_data[303:296];
        7'd42: OUT = map_data[311:304];
        7'd43: OUT = map_data[319:312];
        7'd44: OUT = map_data[327:320];
        7'd45: OUT = map_data[335:328];
        7'd46: OUT = map_data[343:336];
        7'd47: OUT = map_data[351:344];
        7'd48: OUT = map_data[359:352];
        7'd49: OUT = map_data[367:360];
        7'd50: OUT = map_data[375:368];
        7'd51: OUT = map_data[383:376];
        7'd52: OUT = map_data[391:384];
        7'd53: OUT = map_data[399:392];
        7'd54: OUT = map_data[407:400];
        7'd55: OUT = map_data[415:408];
        7'd56: OUT = map_data[423:416];
        7'd57: OUT = map_data[431:424];
        7'd58: OUT = map_data[439:432];
        7'd59: OUT = map_data[447:440];
        7'd60: OUT = map_data[455:448];
        7'd61: OUT = map_data[463:456];
        7'd62: OUT = map_data[471:464];
        7'd63: OUT = map_data[479:472];
        7'd64: OUT = map_data[487:480];
        7'd65: OUT = map_data[495:488];
        7'd66: OUT = map_data[503:496];
        7'd67: OUT = map_data[511:504];
        7'd68: OUT = end_byte;
        default: OUT = 8'h00;
    endcase
end

endmodule
