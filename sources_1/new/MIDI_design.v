`timescale 1ns / 1ps

module MIDI_design(
    input clk,
    input MIDI_clk,
    input MIDI_dat,
    output [7:0] out,
    output R_O,
    //--------------- FPGA DEBUG ------------------------------
    //output reg [1:0] state,
    //--------------- FPGA DEBUG ------------------------------
    output reg ERROR
);

parameter WAIT_START_BIT = 0,
          WRITE = 2,
          STOP_BIT = 3;

reg [1:0] state;
reg [7:0] MIDI_buf;
//reg [1:0] MIDI_clk_sync, MIDI_dat_sync;

assign out = MIDI_buf;

reg [2:0] cnt_data;

//assign R_O = (&cnt_data) & (&state);
reg R_O_reg;
initial R_O_reg = 0;
assign R_O = R_O_reg;

initial
begin
    ERROR = 0;
    state = WAIT_START_BIT;
    MIDI_buf = 0;
    //MIDI_clk_sync = 2'b11;
    //MIDI_dat_sync = 2'b11;
    cnt_data = 0;
end


/*
always@(posedge clk)
begin
    MIDI_clk_sync <= {MIDI_clk_sync[0], MIDI_clk};
    MIDI_dat_sync <= {MIDI_dat_sync[0], MIDI_dat};
end
*/

//always@(negedge MIDI_clk_sync[1])
always@(posedge MIDI_clk)
begin
    //R_O_reg <= (&cnt_data) & (&state);
    case(state)
        WAIT_START_BIT: begin
            R_O_reg <= 0;
            cnt_data <= 0;
            ERROR <= 0;
            //if (~MIDI_dat_sync[1]) 
            if (~MIDI_dat) 
            //if (MIDI_dat) 
                state <= WRITE;
        end
        WRITE: begin
            //MIDI_buf <= {MIDI_buf[6:0], MIDI_dat_sync[1]};
            //MIDI_buf <= {MIDI_buf[6:0], MIDI_dat};
            MIDI_buf <= {MIDI_dat, MIDI_buf[7:1]};
            if (cnt_data == 4'd7) 
                 begin state <= STOP_BIT; end 
            else begin cnt_data <= cnt_data + 1; end
        end
        STOP_BIT: begin
            //if (!MIDI_dat_sync[1])
            if (!MIDI_dat)
                ERROR <= 1;
            state <= WAIT_START_BIT;
            R_O_reg <= 1;
        end
    endcase
end

endmodule