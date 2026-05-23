`timescale 1ns / 1ps


module test_MIDI_design(
    input clk
    );

localparam MIDI_CLK_DIV = 4,
           MIDI_CLK_DIV_WIDTH = $clog2(MIDI_CLK_DIV),
           MIDI_BIT_HOLD = MIDI_CLK_DIV * 10,
           MIDI_WAIT_FOR_BUF = MIDI_BIT_HOLD * 2;

reg MIDI_dat;
wire [7:0] out;
wire R_O;
wire ERROR;
    
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
    //0x90 передача
    
    //#MIDI_WAIT_FOR_BUF; $finish; 
    
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
    //0x31 передача
    #40
    #MIDI_WAIT_FOR_BUF; $finish; 
end
  
wire MIDI_clk;
clk_div #(
    .DIV_VAL(MIDI_CLK_DIV)  
) clk_div_inst (
    .clk(clk),
    .clk_out(MIDI_clk)
);

MIDI_design des_unit(
    .clk(clk),
    .MIDI_clk(MIDI_clk),
    .MIDI_dat(MIDI_dat),
    .out(out),
    .R_O(R_O),
    .ERROR(ERROR)
);
endmodule
