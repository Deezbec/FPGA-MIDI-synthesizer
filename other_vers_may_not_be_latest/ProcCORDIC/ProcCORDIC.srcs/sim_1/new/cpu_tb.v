`timescale 1ns / 1ps

module cpu_tb();

reg clk, reset, cr_file;
reg [31:0] amp, freq, faze;
reg [6:0] amount_of_steps;
wire [31:0] sin, cos;

always #10 clk <= ~clk;

cpu uut (
 .clk(clk)
);


CORDICcpuHEAD uut1(
    .clk(clk), .reset(reset), .cr_file(cr_file),
    .amp(amp), .freq(freq), .faze(faze),
    .amount_of_steps(amount_of_steps),
    .sin(sin), .cos(cos)
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
 repeat (64) @(posedge clk);
 $finish;
end


endmodule