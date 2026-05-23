`timescale 1ns / 1ps
module test;

reg clk;

always #5 clk <= ~clk;
//always #10 clk <= ~clk;
initial clk = 1;

wire pwm_out;

//test_sin_gen gen_n_mix(.clk(clk));
//test_mixer_5in_1out mix_test(.clk(clk));
//test_MIDI_design MIDI_1_pack (.clk(clk));
//test_3pack MIDI_3_pack (.clk(clk));
//test_all_not_top test_the_whole_not_top (.clk(clk));
//test_pwm test_pwm ();

test_top test_the_whole (.clk(clk), .pwm_out(pwm_out));

endmodule
