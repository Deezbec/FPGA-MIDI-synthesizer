`timescale 1ns / 1ps


module CORDICcpuHEAD(
    input clk, reset, cr_file,
    input [31:0] amp, freq, faze,
    input [6:0] amount_of_steps,
    output [31:0] sin, cos
    );
    
cpu uut (
 .clk(clk),
 .reset(reset),
 .ro(ro),
 .sin(sin), 
 .cos(cos),
 .askMoreAtan(askMoreAtan)
);

integer file;
reg [2:0] state;
reg [6:0] amount_of_steps_left;

wire ro;
wire [1:0] askMoreAtan;
wire [31:0] sin, cos;

reg [31:0] sinGRAF [31:0];
reg [31:0] sincnt;

initial begin
    state = 0;
    amount_of_steps_left = 0;
    sincnt = 0;
end

always@(posedge clk) begin

    if (ro) begin
        sinGRAF[sincnt] <= sin;
        sincnt <= sincnt + 1;
    end
    
end
    /*
    case (state)
    3'b000: begin
        if (cr_file) state <= 3'b001;
        else if (askMoreAtan != 0) state <= 3'b010;
    end
    3'b001: begin
        
    /*
            file = $fopen("../../../program.txt", "w");
            if (!file) begin
                $display("Ошибка открытия файла!");
                $finish;
            end
            $fwrite(file, "000_00000000000000000000000000000000_000\n");
            $fwrite(file, "001_%032b_000\n", amp);
            $fwrite(file, "001_%032b_001\n", freq);
            $fwrite(file, "001_%032b_010\n", faze);
            $fclose(file); 
            while (amount_of_steps_left < amount_of_steps) begin
                file = $fopen("../../../../program.txt", "w");
                $fwrite(file, "010_00000000000000000000000000000000_000\n", faze);
                amount_of_steps_left = amount_of_steps_left + 1;
                $fclose(file); 
            end
            //$fclose(file);
    //*/
    /*
    end
    3'b010: begin
        
    end
    3'b111: begin
    end
    endcase
    */
//end

endmodule
