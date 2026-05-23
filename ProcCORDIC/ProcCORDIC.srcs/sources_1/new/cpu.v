`timescale 1ns / 1ps


// 31250 бод


module cpu(
    input wire clk,
    input wire reset,
    output reg ro,
    output [31:0] sin, cos
    );
    localparam LIT_SIZE = 32,
               RF_SIZE = 8,
               ADDR_RF_SIZE = $clog2(RF_SIZE),
               COP_SIZE = 3,
               
               //CMD_SIZE = LIT_SIZE + ADDR_RF_SIZE + COP_SIZE,
               CMD_SIZE = 38,
               CMD_MEM_SIZE = 16,
               ADDR_CMD_MEM_SIZE = $clog2(CMD_MEM_SIZE);
    
    localparam NOP = 0,
               LTM = 1,
               STEP = 2,
               JMP = 3,
               INIT = 4,
               QCOR = 5,
               NEW_DOT = 6,
               SEND_RES = 7;
    
    reg [CMD_SIZE - 1 : 0] CMD_RAM [0 : CMD_MEM_SIZE - 1];
    wire signed [31 : 0] atan_table [0 : 30];
    `include "atan_table.vh"
    reg signed [LIT_SIZE - 1 : 0] RF [0 : RF_SIZE - 1];
    reg [ADDR_CMD_MEM_SIZE - 1 : 0] pc;
    reg [ADDR_CMD_MEM_SIZE - 1 : 0] new_pc;
    
    wire [CMD_SIZE - 1          : 0] cmd              = CMD_RAM[pc];
    wire [COP_SIZE - 1          : 0] cop              = cmd [CMD_SIZE - 1                          -: COP_SIZE];
    wire [ADDR_CMD_MEM_SIZE - 1 : 0] addr_to_jump     = cmd [ADDR_RF_SIZE - 1 + ADDR_CMD_MEM_SIZE  -: ADDR_CMD_MEM_SIZE];
    wire [ADDR_RF_SIZE - 1      : 0] addr_m_1         = cmd [ADDR_RF_SIZE - 1                      -: ADDR_RF_SIZE];
    wire [LIT_SIZE - 1          : 0] req_num_of_steps = cmd [CMD_SIZE - 1 - COP_SIZE               -: LIT_SIZE];
    wire [LIT_SIZE - 1          : 0] req_num_of_dots  = cmd [CMD_SIZE - 1 - COP_SIZE               -: LIT_SIZE];
    wire [LIT_SIZE - 1          : 0] literal          = cmd [CMD_SIZE - 1 - COP_SIZE               -: LIT_SIZE];
    
    wire zero = $signed(32'd0);
    wire one = $signed(32'd1);
    
    integer i;
    initial begin
        for(i = 0; i < RF_SIZE; i = i + 1)
            RF[i] = 0;
        $readmemb("cmd_mem.mem", CMD_RAM);
        pc = 0;
        ro = 0;
    end
    
    always @* begin
        
        if (cop == JMP) begin
            new_pc = addr_to_jump;
        end
        else if (cop == STEP && RF[6] < req_num_of_steps - one) begin
            new_pc = pc;
        end
        //else if (cop == NEW_DOT && RF[7] < req_num_of_dots + one) begin
        else if (cop == NEW_DOT) begin
            new_pc = pc - 4;
        end
        else begin new_pc = pc + one; end
    end
    
    always @(posedge clk) begin
        pc <= new_pc;
        if (reset) begin
            pc <= 0;
            for(i = 0; i < RF_SIZE; i = i + 1)
                RF[i] <= 0;
            $readmemb("cmd_mem.mem", CMD_RAM);
            pc <= 0;
            ro = 0;
        end else begin
            case ( cop )
                //NOP:  begin ; end
                LTM: begin 
                    ro <= 0;
                    RF[addr_m_1] <= literal; 
                end
                STEP: begin
                    ro <= 0;
                    if (RF[5][31]) begin   // z[31]
                        RF[3] <= RF[3] + (RF[4] >>> RF[6]); // x += y_sh
                        RF[4] <= RF[4] - (RF[3] >>> RF[6]); // y -= x_sh
                        RF[5] <= RF[5] + atan_table[RF[6]]; //  z += atan[step_num]
                    end else begin
                        RF[3] <= RF[3] - (RF[4] >>> RF[6]); // x -= y_sh
                        RF[4] <= RF[4] + (RF[3] >>> RF[6]); // y += x_sh
                        RF[5] <= RF[5] - atan_table[RF[6]]; //  z -= atan[step_num] 
                    end
                    RF[6] <= RF[6] + one; //step_num + 1
                end
                INIT: begin
                    ro <= 0;
                    RF[3] <= RF[0];
                    RF[4] <= zero;
                    RF[5] <= RF[7] * RF[1] + RF[2];
                    RF[6] <= 0;
                    RF[7] <= (RF[7] + 32'h00007A12);
                end
                QCOR: begin
                    case (RF[5][31:2])
                        2'b01: begin
                            RF[5] <= {2'b00, RF[5][29:0]}; 
                            RF[3] <= zero - RF[4];
                            RF[4] <= RF[3];
                        end
                        2'b10: begin
                            RF[5] <= {2'b11, RF[5][29:0]};
                            RF[3] <= RF[4]; 
                            RF[4] <= zero - RF[3];
                        end
                    endcase
                end
                SEND_RES: begin
                    RF[6] <= 0;
                    ro <= 1;
                end
                
            endcase
    end
    end
    
    assign sin = RF[4];
    assign cos = RF[3];
    
endmodule
