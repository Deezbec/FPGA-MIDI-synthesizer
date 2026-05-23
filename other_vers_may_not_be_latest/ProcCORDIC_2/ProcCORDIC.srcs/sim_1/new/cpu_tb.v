`timescale 1ns / 1ps

module cpu_tb();

reg clk, reset, cr_file;
reg [31:0] amp, freq, faze, sincur, coscur;
reg [6:0] amount_of_steps;

always #10 clk <= ~clk;

wire [31:0] sin, cos;
always@(posedge ro) begin
        sincur <= sin;
        coscur <= cos;
end

cpu uut (
 .clk(clk),
 .reset(reset),
 .ro(ro),
 .sin(sin), 
 .cos(cos),
 .askMoreAtan(askMoreAtan)
);

initial begin
 clk = 0;
 reset = 0;
 cr_file = 0;
 amp = 32'h00010000;
 freq = 32'h40000000;
 faze = 32'h00000000;
 #10;
 cr_file = 1;
 #10
 cr_file = 0;
 amount_of_steps = 7'd30;
 repeat (10000) @(posedge clk);
 $finish;
end


endmodule