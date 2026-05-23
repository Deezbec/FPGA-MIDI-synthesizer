`timescale 1ns / 1ps

module sin_gen #(
parameter sin_num = 0, 
parameter TABLE_VALUE_WIDTH = 33,
parameter TABLE_ANGLE_WIDTH = 10
)(
    input clk,
    input [4:0] note_press,
    input off,
    output signed [TABLE_VALUE_WIDTH-1:0] trig_table_sin
    );

localparam COUNT = 2**TABLE_ANGLE_WIDTH;

reg [63:0] i;
//reg [9:0] i;
//initial i = 0;
initial i = sin_num * 10; // фаза
reg [9:0] trig_table_angle; 
//wire signed [TABLE_VALUE_WIDTH-1:0] trig_table_sin;
wire [13:0] current_gen_delay;

always@ (posedge clk) begin
    //trig_table_angle = ((1 << 10) * i) / 360;
    trig_table_angle = (93 * i) >> 5; // 1024 / 11 / 2^5  // 11*32 = 352 почти 360
    #current_gen_delay;
    i = i + 1;
end

wire [TABLE_VALUE_WIDTH-1:0] sin_table [0:COUNT-1];
`include "sin_table.vh"

wire sin_cond = trig_table_angle >= 0 && trig_table_angle < COUNT/2;

assign trig_table_sin = off ? 0 : (sin_cond ? sin_table[trig_table_angle] : -sin_table[trig_table_angle]);

get_current_gen_delay delay_get(
    .note_press(note_press),
    .current_gen_delay(current_gen_delay)
    );

endmodule
