`timescale 1ns / 1ps

module delta_sigma_with_dither #(
    parameter INPUT_WIDTH = 33,
    parameter ACCUM_WIDTH = 32
)(
    input clk,
    input reset,
    input signed [INPUT_WIDTH-1:0] audio_in,
    output reg pwm_out
);

reg signed [ACCUM_WIDTH-1:0] accumulator;
reg [15:0] lfsr;

// LFSR для дизеринга
always @(posedge clk or posedge reset) begin
    if (reset) begin
        lfsr <= 16'hACE1;
    end else begin
        lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end
end

// Дельта-сигма с дизерингом (маскируем накопленную ошибку)
wire [ACCUM_WIDTH-1:0] dither = { {ACCUM_WIDTH-16{1'b0}}, lfsr };

always @(posedge clk or posedge reset) begin
    if (reset) begin
        accumulator <= 0;
        pwm_out <= 0;
    end else begin
        // Добавляем дизеринг перед накоплением
        accumulator <= accumulator + audio_in + dither;
        pwm_out <= accumulator[ACCUM_WIDTH-1];  // бит переполнения
    end
end

endmodule