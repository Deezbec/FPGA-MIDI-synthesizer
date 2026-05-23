`timescale 1ns / 1ps

// MIDI_CLK_DIV = f_clk / f_midi = 100 * 1'000'000 / 31250 = 3200
module top# (MIDI_CLK_DIV = 320)(
    input clk,
    input reset,
    input MIDI_dat,
    input [15:0] SW,
    output aud_en, // 0
    //--------------- FPGA DEBUG ------------------------------
    output MIDI_not_dat,
    output R_O_three_pack,
    output R_O_pack,
    //output [4:0] note_press,
    output [4:0] active_notes_mask,
    output [7:0] pack_note,
    output [7:0] AN,
    output [6:0] SEG,
    //--------------- FPGA DEBUG ------------------------------
    
    output reg pwm_out
    );
//--------------- FPGA DEBUG ------------------------------
assign MIDI_not_dat = ~MIDI_dat;
//--------------- FPGA DEBUG ------------------------------

localparam SOUND_BITS_NUM = 33,
           MAX_NOTES_NUM = 5,
           MIDI_BIT_HOLD = MIDI_CLK_DIV * 10,
           MAX_SUM_OPERATIONS = 16,
           MAX_SUM_OPERATIONS_CLOG = $clog2(MAX_SUM_OPERATIONS);


///*
clk_wiz_0 clk_wiz (
.reset(~reset),
.clk_in1(clk),
.clk_out1(clk100),
.clk_out2(clk10)
);
//*/

wire clk_used = clk10;

MIDI_debounce midi_debounce_inst (
    .clk(clk_used),  
    .rst(~reset),
    .MIDI_dat_in(MIDI_dat),
    .MIDI_dat_out(MIDI_dat_clean)
);


(* mark_debug = "true" *) wire signed [SOUND_BITS_NUM-1:0] sound;
(* mark_debug = "true" *) wire pwm_out; // НАДО
wire aud_en;
assign aud_en = 1'b0;

/*
wire [9:0] sound_dithered; 

dither #(
    .INPUT_BITS(33),
    .OUTPUT_BITS(10)
) dither_inst (
    .clk(clk_used),
    .audio_in(sound),
    .audio_out(sound_dithered)
);
//*/

///*
audio_pwm #(
    .INPUT_WIDTH(SOUND_BITS_NUM),
    .PWM_RESOLUTION(10)
) pwm (
    .clk(clk_used),
    .reset(~reset),
    .audio_in(sound),
    .pwm_out(pwm_out)
);
//*/
/*
delta_sigma_with_dither #(
    .INPUT_WIDTH(33),
    .ACCUM_WIDTH(24)  
) delta_sigma_inst (
    .clk(clk),
    .reset(reset),
    .audio_in(sound),
    .pwm_out(pwm_out)
);
*/

wire [4:0] note_press;
wire [7:0] note_volume;
wire [2:0] ERROR_three_pack;
(* mark_debug = "true" *) wire R_O_three_pack;
(* mark_debug = "true" *) wire R_O_pack;

(* mark_debug = "true" *) wire [15:0] LED_notes_active_check;
(* mark_debug = "true" *) wire [3:0] active_notes_num;
(* mark_debug = "true" *) wire [4:0] active_notes_mask;
(* mark_debug = "true" *) wire [24 - 1:0] active_notes;
(* mark_debug = "true" *) wire [3:0] note_press_mass_sum;

note_pusher#(
.SOUND_BITS_NUM(SOUND_BITS_NUM),
.MAX_NOTES_NUM(MAX_NOTES_NUM)
) uut2 (
    .clk(clk_used),
    .note_press(note_press),
    .note_volume(note_volume),
    .R_O_three_pack(R_O_three_pack),
    .SW(SW),
    //--------------- FPGA DEBUG ------------------------------
    .LED_notes_active_check(LED_notes_active_check),
    .active_notes_num(active_notes_num),
    .active_notes_mask(active_notes_mask),
    .active_notes(active_notes),
    .note_press_mass_sum(note_press_mass_sum),
    //--------------- FPGA DEBUG ------------------------------
    .sound(sound)
    );

clk_div #(
    .DIV_VAL(MIDI_CLK_DIV)  
) clk_div_inst (
    .clk(clk_used),
    .clk_out(MIDI_clk)
);

wire [7:0] pack;
wire [1:0] state;
MIDI_design uut(
    .clk(clk_used),
    .MIDI_clk(MIDI_clk),
    //.MIDI_dat(MIDI_dat),
    .MIDI_dat(MIDI_dat_clean),
    .out(pack),
    .R_O(R_O_pack),
    .ERROR(ERROR_pack)
);

wire [7:0] pack_note, pack_serv;
MIDI_Three_pack #(MIDI_CLK_DIV) test3(
    .clk(clk_used),
    .MIDI_clk(MIDI_clk),
    .pack(pack),
    .R_O_pack(R_O_pack),
    .ERROR_pack(ERROR_pack),
    .note_press(note_press),
    .note_volume(note_volume),
    .ERROR(ERROR_three_pack),
    //--------------- FPGA DEBUG ------------------------------
    .pack_note(pack_note),
    .pack_serv(pack_serv),
    //--------------- FPGA DEBUG ------------------------------
    .R_O(R_O_three_pack)
    );


wire clk_div_out;
clk_div #(800) clk_div1 (
    .clk(clk_used),
    .clk_out(SevSEG_clk)
);
reg [31:0] NUMBER;
wire [7:0] AN;
wire [6:0] SEG;
initial NUMBER = 0;
//always@ (posedge R_O_pack or posedge clk) begin
always@ (posedge R_O_pack) begin
    NUMBER <= {active_notes_num, note_press_mass_sum, NUMBER[15:0], pack}; // num, sum, 3pack
    //NUMBER <= {active_notes_num, note_press_mass_sum, active_notes}; // num, sum, active_ONE_SHOT
    //NUMBER <= {active_notes_num, note_press_mass_sum, sound[32:9]}; // num, sum, sound бессмыслено звук пихать
end
SevenSegmentLED seg(
    .clk(SevSEG_clk),
    .RESET(~rst),
    .NUMBER(NUMBER),
    .AN_MASK(8'b00000000),
    .AN(AN),
    .SEG(SEG)
); 

endmodule
