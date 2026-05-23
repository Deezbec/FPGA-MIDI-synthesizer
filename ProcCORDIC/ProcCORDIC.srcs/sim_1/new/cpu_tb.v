`timescale 1ns / 1ps

module cpu_tb();

reg clk, reset, cr_file;
reg [15:0] amp, freq, faze, sincur, coscur;
reg [6:0] amount_of_steps;

always #10 clk <= ~clk;

wire [15:0] sin, cos;
wire ro;

always@(posedge ro) begin
        sincur <= sin;
        coscur <= cos;
end

cpu uut (
 .clk(clk),
 .reset(reset),
 .ro(ro),
 .sin(sin), 
 .cos(cos)
);

initial begin
 clk = 0;
 /*
 clk = 0;
 reset = 0;
 cr_file = 0;
 amp = 16'h00010000;
 freq = 16'h40000000;
 faze = 16'h00000000;
 #10;
 cr_file = 1;
 #10
 cr_file = 0;
 amount_of_steps = 7'd30;
 //*/
 repeat (10000) @(posedge clk);
 $finish;
end


endmodule