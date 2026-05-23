module audio_pwm #(
    parameter INPUT_WIDTH = 33,      
    parameter PWM_RESOLUTION = 16   
)(
    input clk,                       
    input reset,
    input signed [INPUT_WIDTH-1:0] audio_in,  
    output reg pwm_out
);

localparam PWM_BITS = PWM_RESOLUTION; 
localparam PWM_MAX = (1 << PWM_BITS) - 1;
localparam PWM_CENTER = (1 << (PWM_BITS - 1));

reg [PWM_BITS-1:0] pwm_counter;
reg [PWM_BITS-1:0] pwm_threshold;
reg [PWM_BITS-1:0] audio_scaled_reg;  

initial begin
    pwm_counter = 0;
    pwm_threshold = PWM_CENTER;
    pwm_out = 0;
    audio_scaled_reg = 0;
end

always @(posedge clk) begin
    audio_scaled_reg <= 
        (audio_in[INPUT_WIDTH-1:INPUT_WIDTH-PWM_BITS] + 
         {1'b0, audio_in[INPUT_WIDTH-PWM_BITS-1]})  
        + PWM_CENTER;  
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pwm_counter <= 0;
        pwm_threshold <= PWM_CENTER;
        pwm_out <= 0;
    end else begin
        pwm_counter <= pwm_counter + 1;
        
        if (pwm_counter == 0) begin
            pwm_threshold <= audio_scaled_reg;
        end
        
        pwm_out <= (pwm_counter < pwm_threshold);
    end
end

endmodule