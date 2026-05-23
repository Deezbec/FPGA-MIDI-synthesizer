`timescale 1ns / 1ps

module dither #(
    parameter INPUT_BITS = 33,
    parameter OUTPUT_BITS = 10
)(
    input clk,
    input signed [INPUT_BITS-1:0] audio_in,
    output signed [OUTPUT_BITS-1:0] audio_out
);

// LFSR генератор случайного шума
reg [15:0] lfsr;
initial lfsr = 16'hACE1;

always @(posedge clk) begin
    lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
end

// Масштабируем шум под младшие биты
//wire [INPUT_BITS-1:0] noise = { {INPUT_BITS-16{1'b0}}, lfsr[15:INPUT_BITS-OUTPUT_BITS] };
wire [INPUT_BITS-1:0] noise = { {INPUT_BITS-16{1'b0}}, lfsr };

// Добавляем шум перед квантованием
wire signed [INPUT_BITS:0] with_dither = audio_in + noise;

// Квантование с округлением
assign audio_out = with_dither[INPUT_BITS-1:INPUT_BITS-OUTPUT_BITS] + 
                   with_dither[INPUT_BITS-OUTPUT_BITS-1];

endmodule