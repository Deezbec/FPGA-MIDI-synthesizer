`timescale 1ns / 1ps

module test_sin_gen(
    input clk
    );
    
localparam TABLE_VALUE_WIDTH = 33;

wire signed [TABLE_VALUE_WIDTH-1:0] sin1;
wire signed [TABLE_VALUE_WIDTH-1:0] sin2;
wire signed [TABLE_VALUE_WIDTH-1:0] mix;

assign mix = (sin1 + sin2) >>> 1'b1;

sin_gen uut(
    .clk(clk),
    .note_press(6'd0),     
    .off(1'b0),       
    .trig_table_sin(sin1)
);

sin_gen uut2(
    .clk(clk),      
    .note_press(6'd10),      
    .off(1'b0),  
    .trig_table_sin(sin2)
);
endmodule
