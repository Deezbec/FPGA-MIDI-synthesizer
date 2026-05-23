`timescale 1ns / 1ps

module get_current_gen_delay(
    input [4:0] note_press,
    output reg [13:0] current_gen_delay
    );
    
reg [13:0] note_delay [0:23];
wire [13:0] current_gen_delay;
initial begin
    note_delay[0]  = 10617;  // C4
    note_delay[1]  = 10022;  // C#4
    note_delay[2]  = 9458;   // D4
    note_delay[3]  = 8928;   // D#4
    note_delay[4]  = 8428;   // E4
    note_delay[5]  = 7953;   // F4
    note_delay[6]  = 7508;   // F#4
    note_delay[7]  = 7086;   // G4
    note_delay[8]  = 6689;   // G#4
    note_delay[9]  = 6313;   // A4
    note_delay[10] = 5958;   // A#4
    note_delay[11] = 5625;   // B4
    note_delay[12] = 5309;   // C5
    note_delay[13] = 5011;   // C#5
    note_delay[14] = 4730;   // D5
    note_delay[15] = 4464;   // D#5
    note_delay[16] = 4214;   // E5
    note_delay[17] = 3977;   // F5
    note_delay[18] = 3754;   // F#5
    note_delay[19] = 3544;   // G5
    note_delay[20] = 3345;   // G#5
    note_delay[21] = 3157;   // A5
    note_delay[22] = 2980;   // A#5
    note_delay[23] = 2813;   // B5
end

/*
папо¬апапа

*/

assign current_gen_delay = note_delay[note_press];    
endmodule
