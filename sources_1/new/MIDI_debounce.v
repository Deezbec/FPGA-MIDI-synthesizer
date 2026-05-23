`timescale 1ns / 1ps

module MIDI_debounce (
    input clk,        
    input rst,
    input MIDI_dat_in,
    output MIDI_dat_out
);

localparam SAMPLE_COUNT = 8;
localparam SAMPLE_BITS = $clog2(SAMPLE_COUNT);

wire clk_1mhz;
reg [SAMPLE_BITS-1:0] sample_counter;
reg current_state;

initial begin
    sample_counter = 0;
    current_state = 0;
end

clk_div #(
    .DIV_VAL(100)
) clk_div_inst (
    .clk(clk),
    .clk_out(clk_1mhz)
);

always @(posedge clk_1mhz or posedge rst) begin
    if (rst) begin
        sample_counter <= 0;
        current_state <= 1;
    end else begin
        if (MIDI_dat_in == current_state) begin
            if (sample_counter < SAMPLE_COUNT - 1)
                sample_counter <= sample_counter + 1;
        end else begin
            if (sample_counter == 0)
                current_state <= MIDI_dat_in;
            else
                sample_counter <= sample_counter - 1;
        end
    end
end

assign MIDI_dat_out = current_state;

endmodule