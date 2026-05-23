module clk_div #(
    parameter DIV_VAL = 8  // четный
) (
    input clk,
    output reg clk_out
);
    reg [$clog2(DIV_VAL)-1:0] counter;
    initial begin counter = 0; clk_out = 0; end
    
    always @(posedge clk) begin
        if (counter == DIV_VAL/2 - 1) begin
            clk_out <= ~clk_out;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule