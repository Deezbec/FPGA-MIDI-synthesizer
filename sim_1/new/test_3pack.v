`timescale 1ns / 1ps


module test_3pack(
    input clk
    );

localparam MIDI_CLK_DIV = 4,
           MIDI_CLK_DIV_WIDTH = $clog2(MIDI_CLK_DIV),
           MIDI_BIT_HOLD = MIDI_CLK_DIV * 10,
           MIDI_WAIT_FOR_BUF = MIDI_BIT_HOLD * 4;

reg MIDI_dat;
    
initial begin
    MIDI_dat = 1; #10; // молчание
    
    MIDI_dat = 0; #MIDI_BIT_HOLD; // нач пакета
    MIDI_dat = 1; #MIDI_BIT_HOLD; // \
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |  9
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |
    MIDI_dat = 1; #MIDI_BIT_HOLD; // /
    MIDI_dat = 0; #MIDI_BIT_HOLD; // \
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |  0
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |
    MIDI_dat = 0; #MIDI_BIT_HOLD; // /
    MIDI_dat = 1; #MIDI_BIT_HOLD; // конец пакета    
    
    MIDI_dat = 0; #MIDI_BIT_HOLD; // нач пакета
    MIDI_dat = 0; #MIDI_BIT_HOLD; // \
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |  3
    MIDI_dat = 1; #MIDI_BIT_HOLD; // |
    MIDI_dat = 1; #MIDI_BIT_HOLD; // /
    MIDI_dat = 0; #MIDI_BIT_HOLD; // \
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |  1
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |
    MIDI_dat = 1; #MIDI_BIT_HOLD; // /
    MIDI_dat = 1; #MIDI_BIT_HOLD; // конец пакета
  
    MIDI_dat = 0; #MIDI_BIT_HOLD; // нач пакета
    MIDI_dat = 1; #MIDI_BIT_HOLD; // \
    MIDI_dat = 1; #MIDI_BIT_HOLD; // |  F
    MIDI_dat = 1; #MIDI_BIT_HOLD; // |
    MIDI_dat = 1; #MIDI_BIT_HOLD; // /
    MIDI_dat = 1; #MIDI_BIT_HOLD; // \
    MIDI_dat = 0; #MIDI_BIT_HOLD; // |  A
    MIDI_dat = 1; #MIDI_BIT_HOLD; // |
    MIDI_dat = 0; #MIDI_BIT_HOLD; // /
    MIDI_dat = 1; #MIDI_BIT_HOLD; // конец пакета
    
    
    #MIDI_WAIT_FOR_BUF; $finish; 
end


wire [4:0] note_press;
wire [7:0] note_volume;
wire [1:0] ERROR;
wire R_O;
MIDI_Three_pack test3(
    .clk(clk),
    .MIDI_clk(MIDI_clk),
    .MIDI_dat(MIDI_dat),
    .note_press(note_press),
    .note_volume(note_volume),
    .ERROR(ERROR),
    .R_O(R_O)
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
wire ERROR__pack;
MIDI_design des_unit(
    .clk(clk),
    .MIDI_clk(MIDI_clk),
    .MIDI_dat(MIDI_dat),
    .out(pack),
    .R_O(R_O_pack),
    .ERROR(ERROR__pack)
);
endmodule
