/*------------------------------------------------------------------------
 * Arquivo   : mux133x1.v
 * Projeto   : BitBakery - Delivery Game
 *------------------------------------------------------------------------
 * Descricao : multiplexador 133x1 para transmissão serial
 *             Transmite: 1 start + 3 dados + 64 obstacle bytes + 64 objective bytes + 1 end = 133 bytes
 *------------------------------------------------------------------------
 */

module mux133x1 (
    input [7:0] start_byte,         // 0xFF
    input [7:0] D0,                 // Data byte 0
    input [7:0] D1,                 // Data byte 1
    input [7:0] D2,                 // Data byte 2
    input [511:0] map_obstacles,    // 128 rows * 4 bits = 512 bits = 64 bytes
    input [511:0] map_objectives,   // 128 rows * 4 bits = 512 bits = 64 bytes
    input [7:0] end_byte,           // 0xFE
    input [7:0] SEL,                // 8 bits to select 0-132
    output reg [7:0] OUT
);

always @(*) begin
    case (SEL)
        8'd0:  OUT = start_byte;
        8'd1:  OUT = D0;
        8'd2:  OUT = D1;
        8'd3:  OUT = D2;
        // Map obstacles data bytes (64 bytes for 512 bits)
        8'd4:  OUT = map_obstacles[7:0];
        8'd5:  OUT = map_obstacles[15:8];
        8'd6:  OUT = map_obstacles[23:16];
        8'd7:  OUT = map_obstacles[31:24];
        8'd8:  OUT = map_obstacles[39:32];
        8'd9:  OUT = map_obstacles[47:40];
        8'd10: OUT = map_obstacles[55:48];
        8'd11: OUT = map_obstacles[63:56];
        8'd12: OUT = map_obstacles[71:64];
        8'd13: OUT = map_obstacles[79:72];
        8'd14: OUT = map_obstacles[87:80];
        8'd15: OUT = map_obstacles[95:88];
        8'd16: OUT = map_obstacles[103:96];
        8'd17: OUT = map_obstacles[111:104];
        8'd18: OUT = map_obstacles[119:112];
        8'd19: OUT = map_obstacles[127:120];
        8'd20: OUT = map_obstacles[135:128];
        8'd21: OUT = map_obstacles[143:136];
        8'd22: OUT = map_obstacles[151:144];
        8'd23: OUT = map_obstacles[159:152];
        8'd24: OUT = map_obstacles[167:160];
        8'd25: OUT = map_obstacles[175:168];
        8'd26: OUT = map_obstacles[183:176];
        8'd27: OUT = map_obstacles[191:184];
        8'd28: OUT = map_obstacles[199:192];
        8'd29: OUT = map_obstacles[207:200];
        8'd30: OUT = map_obstacles[215:208];
        8'd31: OUT = map_obstacles[223:216];
        8'd32: OUT = map_obstacles[231:224];
        8'd33: OUT = map_obstacles[239:232];
        8'd34: OUT = map_obstacles[247:240];
        8'd35: OUT = map_obstacles[255:248];
        8'd36: OUT = map_obstacles[263:256];
        8'd37: OUT = map_obstacles[271:264];
        8'd38: OUT = map_obstacles[279:272];
        8'd39: OUT = map_obstacles[287:280];
        8'd40: OUT = map_obstacles[295:288];
        8'd41: OUT = map_obstacles[303:296];
        8'd42: OUT = map_obstacles[311:304];
        8'd43: OUT = map_obstacles[319:312];
        8'd44: OUT = map_obstacles[327:320];
        8'd45: OUT = map_obstacles[335:328];
        8'd46: OUT = map_obstacles[343:336];
        8'd47: OUT = map_obstacles[351:344];
        8'd48: OUT = map_obstacles[359:352];
        8'd49: OUT = map_obstacles[367:360];
        8'd50: OUT = map_obstacles[375:368];
        8'd51: OUT = map_obstacles[383:376];
        8'd52: OUT = map_obstacles[391:384];
        8'd53: OUT = map_obstacles[399:392];
        8'd54: OUT = map_obstacles[407:400];
        8'd55: OUT = map_obstacles[415:408];
        8'd56: OUT = map_obstacles[423:416];
        8'd57: OUT = map_obstacles[431:424];
        8'd58: OUT = map_obstacles[439:432];
        8'd59: OUT = map_obstacles[447:440];
        8'd60: OUT = map_obstacles[455:448];
        8'd61: OUT = map_obstacles[463:456];
        8'd62: OUT = map_obstacles[471:464];
        8'd63: OUT = map_obstacles[479:472];
        8'd64: OUT = map_obstacles[487:480];
        8'd65: OUT = map_obstacles[495:488];
        8'd66: OUT = map_obstacles[503:496];
        8'd67: OUT = map_obstacles[511:504];
        // Map objectives data bytes (64 bytes for 512 bits)
        8'd68:  OUT = map_objectives[7:0];
        8'd69:  OUT = map_objectives[15:8];
        8'd70:  OUT = map_objectives[23:16];
        8'd71:  OUT = map_objectives[31:24];
        8'd72:  OUT = map_objectives[39:32];
        8'd73:  OUT = map_objectives[47:40];
        8'd74:  OUT = map_objectives[55:48];
        8'd75:  OUT = map_objectives[63:56];
        8'd76:  OUT = map_objectives[71:64];
        8'd77:  OUT = map_objectives[79:72];
        8'd78:  OUT = map_objectives[87:80];
        8'd79:  OUT = map_objectives[95:88];
        8'd80:  OUT = map_objectives[103:96];
        8'd81:  OUT = map_objectives[111:104];
        8'd82:  OUT = map_objectives[119:112];
        8'd83:  OUT = map_objectives[127:120];
        8'd84:  OUT = map_objectives[135:128];
        8'd85:  OUT = map_objectives[143:136];
        8'd86:  OUT = map_objectives[151:144];
        8'd87:  OUT = map_objectives[159:152];
        8'd88:  OUT = map_objectives[167:160];
        8'd89:  OUT = map_objectives[175:168];
        8'd90:  OUT = map_objectives[183:176];
        8'd91:  OUT = map_objectives[191:184];
        8'd92:  OUT = map_objectives[199:192];
        8'd93:  OUT = map_objectives[207:200];
        8'd94:  OUT = map_objectives[215:208];
        8'd95:  OUT = map_objectives[223:216];
        8'd96:  OUT = map_objectives[231:224];
        8'd97:  OUT = map_objectives[239:232];
        8'd98:  OUT = map_objectives[247:240];
        8'd99:  OUT = map_objectives[255:248];
        8'd100: OUT = map_objectives[263:256];
        8'd101: OUT = map_objectives[271:264];
        8'd102: OUT = map_objectives[279:272];
        8'd103: OUT = map_objectives[287:280];
        8'd104: OUT = map_objectives[295:288];
        8'd105: OUT = map_objectives[303:296];
        8'd106: OUT = map_objectives[311:304];
        8'd107: OUT = map_objectives[319:312];
        8'd108: OUT = map_objectives[327:320];
        8'd109: OUT = map_objectives[335:328];
        8'd110: OUT = map_objectives[343:336];
        8'd111: OUT = map_objectives[351:344];
        8'd112: OUT = map_objectives[359:352];
        8'd113: OUT = map_objectives[367:360];
        8'd114: OUT = map_objectives[375:368];
        8'd115: OUT = map_objectives[383:376];
        8'd116: OUT = map_objectives[391:384];
        8'd117: OUT = map_objectives[399:392];
        8'd118: OUT = map_objectives[407:400];
        8'd119: OUT = map_objectives[415:408];
        8'd120: OUT = map_objectives[423:416];
        8'd121: OUT = map_objectives[431:424];
        8'd122: OUT = map_objectives[439:432];
        8'd123: OUT = map_objectives[447:440];
        8'd124: OUT = map_objectives[455:448];
        8'd125: OUT = map_objectives[463:456];
        8'd126: OUT = map_objectives[471:464];
        8'd127: OUT = map_objectives[479:472];
        8'd128: OUT = map_objectives[487:480];
        8'd129: OUT = map_objectives[495:488];
        8'd130: OUT = map_objectives[503:496];
        8'd131: OUT = map_objectives[511:504];
        8'd132: OUT = end_byte;
        default: OUT = 8'h00;
    endcase
end

endmodule
