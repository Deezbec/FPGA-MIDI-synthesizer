`timescale 1ns / 1ps

module MIDI_Three_pack # (MIDI_CLK_DIV = 3200)(
    input clk,
    input MIDI_clk,
    input [7:0] pack,
    input R_O_pack,
    input ERROR_pack,
    output [4:0] note_press,
    output [7:0] note_volume,
    output reg [2:0] ERROR,
    //--------------- FPGA DEBUG ------------------------------
    output [7:0] pack_note,
    output [7:0] pack_serv,
    //--------------- FPGA DEBUG ------------------------------
    output R_O
    );

localparam NUM_OF_PACKS_IN_MSG = 3;

reg [7:0] pack_serv, pack_note, pack_volume;
reg [2:0] pack_cnt;
reg R_O_reg, read, read90;

initial
begin
    pack_note = 0;
    pack_serv = 0;
    pack_volume = 0;
    ERROR = 0;
    pack_cnt = 3'b000;
    read = 0;
    R_O_reg = 0;
    read90 = 0;
end

assign note_press = {~pack_note[4], pack_note[3:0]};
assign note_volume = pack_volume;
assign R_O = R_O_reg;

always@(posedge MIDI_clk) begin
    if (R_O_pack) begin
        pack_cnt <= (pack == 16'hFF) ? 0 : (&pack_cnt)? 3'b100 : {1'b1, pack_cnt[2:1]};
        read <= 1'b0;
    end
    else read <= 1'b1;
end

always@(posedge clk)
begin
    //if (R_O_pack) begin
        R_O_reg <= 0;
        if (&pack_cnt) begin 
            ERROR <= 3'b000;
        end
        if (~read) begin
            case(pack_cnt)
                3'b100: begin
                    if (ERROR_pack) ERROR[0] <= 1'b1;
                    if (pack == 16'h90) begin 
                        pack_serv <= pack;
                        read90 <= 0;
                    end
                end
                3'b110: begin
                    if (ERROR_pack) ERROR[1] <= 1'b1;
                    if (pack_serv == 16'h90) pack_note <= pack;
                end
                3'b111: begin
                    if (ERROR_pack) ERROR[2] <= 1'b1;
                    if (pack_serv == 16'h90) begin 
                        pack_volume <= pack;
                        read90 <= 1;
                    end
                    //if (pack_serv == 16'h90) R_O_reg <= 1;
                    R_O_reg <= 1;
                end
            endcase
            
        end
    //end
end

endmodule
