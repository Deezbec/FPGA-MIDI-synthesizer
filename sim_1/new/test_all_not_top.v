`timescale 1ns / 1ps


module test_all_not_top(
    input clk
    );

localparam MIDI_CLK_DIV = 4,
           MIDI_BIT_HOLD = MIDI_CLK_DIV * 10;

reg MIDI_dat_gen;
wire MIDI_dat;
assign MIDI_dat = MIDI_dat_gen;

task gen_midi_three_pack;
    input [7:0] status;   
    input [7:0] note;  
    input [7:0] velocity; 
    integer i;
begin
    MIDI_dat_gen = 0; #MIDI_BIT_HOLD; 
    for (i = 7; i >= 0; i = i - 1) begin
        MIDI_dat_gen = status[i]; #MIDI_BIT_HOLD;
    end
    MIDI_dat_gen = 1; #MIDI_BIT_HOLD; 
    
    MIDI_dat_gen = 0; #MIDI_BIT_HOLD; 
    for (i = 7; i >= 0; i = i - 1) begin
        MIDI_dat_gen = note[i]; #MIDI_BIT_HOLD;
    end
    MIDI_dat_gen = 1; #MIDI_BIT_HOLD; 
    
    MIDI_dat_gen = 0; #MIDI_BIT_HOLD; 
    for (i = 7; i >= 0; i = i - 1) begin
        MIDI_dat_gen = velocity[i]; #MIDI_BIT_HOLD; 
    end
    MIDI_dat_gen = 1; #MIDI_BIT_HOLD; 
end
endtask

localparam timewait = 10000000; 
initial begin
    gen_midi_three_pack(8'h90, 8'h10, 8'hAA); #timewait;
    gen_midi_three_pack(8'h90, 8'h12, 8'hAA); #timewait;
    gen_midi_three_pack(8'h90, 8'h1, 8'hAA); #timewait;
    gen_midi_three_pack(8'h90, 8'h5, 8'hAA); #timewait;
    gen_midi_three_pack(8'h90, 8'h20, 8'hAA); #timewait;
    gen_midi_three_pack(8'h90, 8'h1, 8'h00); #timewait;
    gen_midi_three_pack(8'h90, 8'h12, 8'h00); #timewait;
    gen_midi_three_pack(8'h90, 8'h20, 8'h00); #timewait;
end

localparam TABLE_VALUE_WIDTH = 33;
wire signed [TABLE_VALUE_WIDTH:0] sound;
note_pusher uut2 (
    .clk(clk),
    .note_press(note_press),
    .note_volume(note_volume),
    .R_O_three_pack(R_O_three_pack),
    .sound(sound)
    );

wire [4:0] note_press;
wire [7:0] note_volume;
wire [1:0] ERROR_three_pack;
wire R_O_three_pack;
MIDI_Three_pack test3(
    .clk(clk),
    .MIDI_clk(MIDI_clk),
    .MIDI_dat(MIDI_dat),
    .note_press(note_press),
    .note_volume(note_volume),
    .ERROR(ERROR_three_pack),
    .R_O(R_O_three_pack)
    );

wire MIDI_clk;
clk_div #(
    .DIV_VAL(MIDI_CLK_DIV)  
) clk_div_inst (
    .clk(clk),
    .clk_out(MIDI_clk)
);

wire [7:0] pack;
wire R_O_pack;
wire ERROR_pack;
MIDI_design des_unit(
    .clk(clk),
    .MIDI_clk(MIDI_clk),
    .MIDI_dat(MIDI_dat),
    .out(pack),
    .R_O(R_O_pack),
    .ERROR(ERROR_pack)
);
endmodule
