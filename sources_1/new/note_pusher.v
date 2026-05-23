`timescale 1ns / 1ps

module note_pusher # (
parameter SOUND_BITS_NUM = 33,
parameter MAX_NOTES_NUM = 5
) (
    input clk,
    input [4:0] note_press,
    input [7:0] note_volume,
    input R_O_three_pack,
    input [15:0] SW,
    //--------------- FPGA DEBUG ------------------------------
    output [15:0] LED_notes_active_check,
    output reg [$clog2(MAX_NOTES_NUM) - 1:0] active_notes_num,
    output reg [MAX_NOTES_NUM - 1:0] active_notes_mask,
    output reg [24 - 1:0] active_notes,
    output reg [3:0] note_press_mass_sum,
    //--------------- FPGA DEBUG ------------------------------
    output [SOUND_BITS_NUM-1:0] sound
    );

localparam TABLE_VALUE_WIDTH = 33,
           TABLE_ANGLE_WIDTH = 10,
           COUNT = 2**TABLE_ANGLE_WIDTH,
           MAX_NOTES_NUM_CLOG = $clog2(MAX_NOTES_NUM),
           SYNTHESISED_NOTES_AMOUNT = 24,
           SYNTHESISED_NOTES_AMOUNT_CLOG = $clog2(SYNTHESISED_NOTES_AMOUNT);

//reg [MAX_NOTES_NUM_CLOG - 1:0] active_notes_num;
//reg [MAX_NOTES_NUM - 1:0] active_notes_mask;
//reg [SYNTHESISED_NOTES_AMOUNT - 1:0] active_notes;
reg [SYNTHESISED_NOTES_AMOUNT_CLOG - 1:0] note_press_mass [0:MAX_NOTES_NUM - 1];

reg [SYNTHESISED_NOTES_AMOUNT_CLOG - 1:0] k, m;

initial begin
    note_press_mass_sum = 0;
    active_notes_num = 0;
    active_notes = 0;
    active_notes_mask = 0;
    k = 0; m = 0;
    for(k = 0; k < MAX_NOTES_NUM; k = k + 1) begin
        note_press_mass[k] = 0;
    end
end

//--------------- FPGA DEBUG ------------------------------
assign LED_notes_active_check = active_notes[15:0];
//--------------- FPGA DEBUG ------------------------------

always @(posedge clk) begin
    /*
    note_press_mass_sum <= note_press_mass[0] + 
                                note_press_mass[1] + 
                                note_press_mass[2] + 
                                note_press_mass[3] + 
                                note_press_mass[4];
                                */
    if (~SW[15]) begin
        ///*
        if(R_O_three_pack) begin
            if (note_volume == 8'd0 & active_notes_num >= 0 & active_notes[note_press]) begin 
                active_notes[note_press] <= 0;
                active_notes_num <= active_notes_num - 1;
                active_notes_mask <= {1'b0, {active_notes_mask[MAX_NOTES_NUM - 1:1]}};
                m = 0; 
                for(k = 0; k < SYNTHESISED_NOTES_AMOUNT; k = k + 1) begin 
                    if (active_notes[k] & m < MAX_NOTES_NUM) begin 
                        note_press_mass[m] <= (m < active_notes_num - 1) ? k : 0; 
                        m = m + 1; 
                    end 
                end
            end else begin 
                if(active_notes_num < MAX_NOTES_NUM & ~active_notes[note_press] & ~(note_volume == 8'd0)) begin 
                active_notes[note_press] <= 1;
                active_notes_num <= active_notes_num + 1;
                active_notes_mask <= {{active_notes_mask[MAX_NOTES_NUM - 2:0]}, 1'b1};
                note_press_mass[active_notes_num] <= note_press;
                end 
            end
        end
        //*/
        /* ÐÀÁÎÒÀÅÒ ÍÎ ÌÅÄËÅÍÍÎ
        if(R_O_three_pack) begin
            if (note_volume == 8'd0 & active_notes_num >= 0 & active_notes[note_press]) begin 
                active_notes[note_press] <= 0;
                active_notes_num <= active_notes_num - 1;
                active_notes_mask <= {1'b0, {active_notes_mask[MAX_NOTES_NUM - 1:1]}};
                m = 0; 
                for(k = 0; k < SYNTHESISED_NOTES_AMOUNT; k = k + 1) begin 
                    if (active_notes[k] & m < MAX_NOTES_NUM) begin 
                        note_press_mass[m] <= (m < active_notes_num - 1) ? k : 0; 
                        m = m + 1; 
                    end 
                end
            end else begin 
                if(active_notes_num < MAX_NOTES_NUM & ~active_notes[note_press] & ~(note_volume == 8'd0)) begin 
                active_notes[note_press] <= 1;
                active_notes_num <= active_notes_num + 1;
                active_notes_mask <= {{active_notes_mask[MAX_NOTES_NUM - 2:0]}, 1'b1};
                note_press_mass[active_notes_num] <= note_press;
                end 
            end
        end
        //*/
    end else begin
        // ÌÀÍÓÀËÜÍÛÉ ÐÅÆÈÌ ÑÞÄÀ
        active_notes_num <= SW[0] + SW[1] + SW[2] +  SW[3] +  SW[4] +  SW[5] +  SW[6] + SW[7] +
                            SW[8] + SW[9] + SW[10] + SW[11] + SW[12] + SW[13] + SW[14];
        case (active_notes_num)
            3'b000: active_notes_mask <= 5'b00000;
            3'b001: active_notes_mask <= 5'b00001;
            3'b010: active_notes_mask <= 5'b00011;
            3'b011: active_notes_mask <= 5'b00111;
            3'b100: active_notes_mask <= 5'b01111;
            3'b101: active_notes_mask <= 5'b11111;
            default: active_notes_mask <= 5'b11111;
        endcase 
        m = 0;
        for(k = 0; k < 15; k = k + 1) begin 
            active_notes[k] <= SW[k];
            if (SW[k] & m < active_notes_num) begin
                note_press_mass[m] <= k;
                m = m + 1;
            end
        end
        
    end
end

//-----------------------------------------------------------------------------------------

wire signed [TABLE_VALUE_WIDTH-1:0] sin [0:MAX_NOTES_NUM - 1];

//assign sound = (active_notes_num == 3'd0) ? 0 : ((sin[0] + sin[1] + sin[2] + sin[3] + sin[4]) / active_notes_num);

wire signed [SOUND_BITS_NUM+10:0] sum_temp_temp = sin[0] + sin[1] + sin[2] + sin[3] + sin[4];

reg signed [SOUND_BITS_NUM+10:0] sum_temp;
reg signed [SOUND_BITS_NUM-1:0] sound_reg;
initial begin sum_temp = 0; sound_reg = 0; end



always @(posedge clk) begin

    ///*
    sound_reg = sum_temp_temp / active_notes_num;
    //*/
    /*
    case (active_notes_num)
        0: sound_reg = 0;
        1: sound_reg = sin[0]                                       ;  // ;
        2: sound_reg = (sin[0] + sin[1])                            >>> 1;  // >>> 1;
        3: begin
            sum_temp = sin[0] + sin[1] + sin[2];
            sound_reg = (sum_temp * 341)                            >>> 10; // >>> 10;
        end
        4: sound_reg = (sin[0] + sin[1] + sin[2] + sin[3])          >>> 2 ;      // >>> 2;
        default: begin
            sum_temp = sin[0] + sin[1] + sin[2] + sin[3] + sin[4];
            sound_reg = (sum_temp * 205)                            >>> 10; // >>> 10;
        end
    endcase
    //*/
     casez (sound_reg)
        33'b?1???????????????????????????????: sound_reg <= sound_reg;           
        33'b?01??????????????????????????????: sound_reg <= sound_reg <<< 1;     
        33'b?001?????????????????????????????: sound_reg <= sound_reg <<< 2;     
        33'b?0001????????????????????????????: sound_reg <= sound_reg <<< 3;     
        33'b?00001???????????????????????????: sound_reg <= sound_reg <<< 4;     
        33'b?000001??????????????????????????: sound_reg <= sound_reg <<< 5;     
        33'b?0000001?????????????????????????: sound_reg <= sound_reg <<< 6;     
        33'b?00000001????????????????????????: sound_reg <= sound_reg <<< 7;     
        33'b?000000001???????????????????????: sound_reg <= sound_reg <<< 8;     
        33'b?0000000001??????????????????????: sound_reg <= sound_reg <<< 9;     
        33'b?00000000001?????????????????????: sound_reg <= sound_reg <<< 10;    
        33'b?000000000001????????????????????: sound_reg <= sound_reg <<< 11;    
        33'b?0000000000001???????????????????: sound_reg <= sound_reg <<< 12;    
        33'b?00000000000001??????????????????: sound_reg <= sound_reg <<< 13;    
        33'b?000000000000001?????????????????: sound_reg <= sound_reg <<< 14;    
        33'b?0000000000000001????????????????: sound_reg <= sound_reg <<< 15;    
        33'b?00000000000000001???????????????: sound_reg <= sound_reg <<< 16;    
        33'b?000000000000000001??????????????: sound_reg <= sound_reg <<< 17;    
        33'b?0000000000000000001?????????????: sound_reg <= sound_reg <<< 18;    
        33'b?00000000000000000001????????????: sound_reg <= sound_reg <<< 19;    
        33'b?000000000000000000001???????????: sound_reg <= sound_reg <<< 20;    
        33'b?0000000000000000000001??????????: sound_reg <= sound_reg <<< 21;    
        33'b?00000000000000000000001?????????: sound_reg <= sound_reg <<< 22;    
        33'b?000000000000000000000001????????: sound_reg <= sound_reg <<< 23;    
        33'b?0000000000000000000000001???????: sound_reg <= sound_reg <<< 24;    
        33'b?00000000000000000000000001??????: sound_reg <= sound_reg <<< 25;    
        33'b?000000000000000000000000001?????: sound_reg <= sound_reg <<< 26;    
        33'b?0000000000000000000000000001????: sound_reg <= sound_reg <<< 27;    
        33'b?00000000000000000000000000001???: sound_reg <= sound_reg <<< 28;    
        33'b?000000000000000000000000000001??: sound_reg <= sound_reg <<< 29;    
        33'b?0000000000000000000000000000001?: sound_reg <= sound_reg <<< 30;    
        33'b?00000000000000000000000000000001: sound_reg <= sound_reg <<< 31;    
        default: sound_reg <= sound_reg; 
    endcase
    
end

assign sound = sound_reg;
//*/

//-----------------------------------------------------------------------------------------

genvar i_gen0;
generate
    for (i_gen0 = 0; i_gen0 < MAX_NOTES_NUM; i_gen0 = i_gen0 + 1) begin : gen_sin
        sin_gen_acc #( 
        //sin_gen #( 
            .sin_num(i_gen0),
            .TABLE_VALUE_WIDTH(TABLE_VALUE_WIDTH),
            .TABLE_ANGLE_WIDTH(10)
        ) uut (
            .clk(clk),
            .note_press(note_press_mass[i_gen0]),
            .off(~active_notes_mask[i_gen0]),
            .trig_table_sin(sin[i_gen0])
        );
    end
endgenerate

endmodule