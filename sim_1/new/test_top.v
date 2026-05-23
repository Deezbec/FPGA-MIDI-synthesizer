`timescale 1ns / 1ps


module test_top(
    input clk,
    output pwm_out
    );

reg MIDI_dat_gen;
wire MIDI_dat;
assign MIDI_dat = MIDI_dat_gen;
assign MIDI_not_dat = ~MIDI_dat_gen;

localparam MIDI_CLK_DIV = 3200, //4
           MIDI_CLK_DIV_WIDTH = $clog2(MIDI_CLK_DIV),
           MIDI_BIT_HOLD = MIDI_CLK_DIV * 10,
           MIDI_WAIT_FOR_BUF = MIDI_BIT_HOLD * 4;

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

reg reset;
localparam WAIT_MORE = 10;
localparam timewait = 10000000 * WAIT_MORE; 
localparam timewait_half = timewait / 2; 
reg [15:0] SW; //SW[15] == 1 -- ���������� ����� ����������� ������, ����� ����. 
initial SW = 0;
wire aud_en;
initial begin
    reset = 1'b0;
    /*
    #timewait; // ��� ���� �� ���������� phase_acc � sin_gen_acc
    
    SW[15] = 1; // ���������� ����� - ��� �������
    SW[14] = 1; #timewait;
    SW[13] = 1; #timewait;
    SW[14] = 0; #timewait;
    SW[13] = 0; #timewait;
    //*/
    
    ///*
    SW[15] = 0;
    gen_midi_three_pack(8'h90, 8'h32, 8'hAA); #timewait;
    //gen_midi_three_pack(8'h90, 8'h31, 8'hAA); #timewait;
    //gen_midi_three_pack(8'h90, 8'h3F, 8'hAA); #timewait;
    //gen_midi_three_pack(8'h90, 8'h32, 8'h00); #timewait;
    //gen_midi_three_pack(8'h90, 8'h31, 8'h00); #timewait;
    //gen_midi_three_pack(8'h90, 8'h3F, 8'h00); #timewait;
    //*/
end

wire [9:0] LED_notes_active_check;
top #(MIDI_CLK_DIV) uut(
    .clk(clk),
    .reset(reset),
    .MIDI_dat(MIDI_dat),
    .SW(SW),
    .aud_en(aud_en),
    //--------------- FPGA DEBUG ------------------------------
    /*
    //.LED_notes_active_check(LED_notes_active_check),
    //.MIDI_dat_check(MIDI_dat_check),
    //.R_O_three_pack(R_O_three_pack),
    //.R_O_pack(R_O_pack),
    //.note_press(note_press),
    //.pack(pack),
    //output [7:0] note_volume
    //*/
    //--------------- FPGA DEBUG ------------------------------
    .pwm_out(pwm_out)
    );


endmodule