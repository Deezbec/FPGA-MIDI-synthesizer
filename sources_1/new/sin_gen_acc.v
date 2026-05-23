`timescale 1ns / 1ps

module sin_gen_acc #(
    parameter sin_num = 0,
    parameter TABLE_VALUE_WIDTH = 33,
    parameter TABLE_ANGLE_WIDTH = 10
)(
    input clk,
    input [4:0] note_press,
    input off,
    output reg signed [TABLE_VALUE_WIDTH-1:0] trig_table_sin
);

localparam COUNT = 2**TABLE_ANGLE_WIDTH;
localparam PHASE_WIDTH = 32;

reg [PHASE_WIDTH-1:0] phase_acc;
wire [PHASE_WIDTH-1:0] phase_inc;

localparam PHASE_STEP = 32'h33333333;

initial begin
    //phase_acc = 0;
    phase_acc = sin_num * PHASE_STEP; //фаза. 5 кол-во нот
    //phase_acc = sin_num * (2**PHASE_WIDTH / 5); //фаза. 5 кол-во нот
end

wire [31:0] phase_inc_table [0:23];

//phase_inc = (f_out ? 2^N) / f_clk
//N = 32 - разрядность акк фазы
//f_out - искомая частота в ГЦ
//f_clk - 100 МГц
assign phase_inc_table[0]  = 32'd11235;  // C4  (261.63 Hz)
assign phase_inc_table[1]  = 32'd11900;  // C#4 (277.18 Hz)
assign phase_inc_table[2]  = 32'd12605;  // D4  (293.66 Hz)
assign phase_inc_table[3]  = 32'd13355;  // D#4 (311.13 Hz)
assign phase_inc_table[4]  = 32'd14148;  // E4  (329.63 Hz)
assign phase_inc_table[5]  = 32'd14986;  // F4  (349.23 Hz)
assign phase_inc_table[6]  = 32'd15877;  // F#4 (369.99 Hz)
assign phase_inc_table[7]  = 32'd16826;  // G4  (392.00 Hz)
assign phase_inc_table[8]  = 32'd17825;  // G#4 (415.30 Hz)
assign phase_inc_table[9]  = 32'd18885;  // A4  (440.00 Hz)
assign phase_inc_table[10] = 32'd20008;  // A#4 (466.16 Hz)
assign phase_inc_table[11] = 32'd21195;  // B4  (493.88 Hz)
assign phase_inc_table[12] = 32'd22461;  // C5  (523.25 Hz)
assign phase_inc_table[13] = 32'd23797;  // C#5 (554.37 Hz)
assign phase_inc_table[14] = 32'd25210;  // D5  (587.33 Hz)
assign phase_inc_table[15] = 32'd26711;  // D#5 (622.25 Hz)
assign phase_inc_table[16] = 32'd28306;  // E5  (659.25 Hz)
assign phase_inc_table[17] = 32'd29981;  // F5  (698.46 Hz)
assign phase_inc_table[18] = 32'd31763;  // F#5 (739.99 Hz)
assign phase_inc_table[19] = 32'd33661;  // G5  (783.99 Hz)
assign phase_inc_table[20] = 32'd35656;  // G#5 (830.61 Hz)
assign phase_inc_table[21] = 32'd37776;  // A5  (880.00 Hz)
assign phase_inc_table[22] = 32'd40016;  // A#5 (932.33 Hz)
assign phase_inc_table[23] = 32'd42390;  // B5  (987.77 Hz)

assign phase_inc = phase_inc_table[note_press];

wire [TABLE_VALUE_WIDTH-1:0] sin_table [0:COUNT-1];
`include "sin_table.vh"

always @(posedge clk) begin
    if (off) begin
        phase_acc <= 0;
    end else begin
        phase_acc <= phase_acc + phase_inc;
    end
end

wire [TABLE_ANGLE_WIDTH-1:0] trig_table_angle;
assign trig_table_angle = phase_acc[PHASE_WIDTH-1:PHASE_WIDTH-TABLE_ANGLE_WIDTH];

wire sin_cond = trig_table_angle < COUNT/2;

always @(posedge clk) begin
    if (off) begin
        trig_table_sin <= 0;
    end else begin
        if (sin_cond)
            trig_table_sin <= sin_table[trig_table_angle];
        else
            trig_table_sin <= -sin_table[trig_table_angle - COUNT/2];
    end
end

endmodule