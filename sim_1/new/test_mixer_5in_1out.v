`timescale 1ns / 1ps

module test_mixer_5in_1out(
    input clk
    );
    


reg [4:0] note_press;
reg [7:0] note_volume;
reg R_O_three_pack;


localparam TABLE_VALUE_WIDTH = 33;
wire signed [TABLE_VALUE_WIDTH:0] sound;
note_pusher uut2 (
    .clk(clk),
    .note_press(note_press),
    .note_volume(note_volume),
    .R_O_three_pack(R_O_three_pack),
    .sound(sound)
    );
   
localparam timewait = 10000000; 
initial begin
    R_O_three_pack = 0;

    note_press = 5'd10;
    note_volume = 16'hAA;
    R_O_three_pack = 1; #10;
    R_O_three_pack = 0; #10;
    
    #timewait;
    
    note_press = 5'd12;
    note_volume = 16'hAA;
    R_O_three_pack = 1; #10;
    R_O_three_pack = 0; #10;
    
    #timewait;
    
    note_press = 5'd1;
    note_volume = 16'hAA;
    R_O_three_pack = 1; #10;
    R_O_three_pack = 0; #10;
    
    #timewait;
    
    note_press = 5'd5;
    note_volume = 16'hAA;
    R_O_three_pack = 1; #10;
    R_O_three_pack = 0; #10;
    
    #timewait;
    
    note_press = 5'd20;
    note_volume = 16'hAA;
    R_O_three_pack = 1; #10;
    R_O_three_pack = 0; #10;
    
    #timewait;
    
    note_press = 5'd1;
    note_volume = 16'h00;
    R_O_three_pack = 1; #10;
    R_O_three_pack = 0; #10;
end
    
endmodule
