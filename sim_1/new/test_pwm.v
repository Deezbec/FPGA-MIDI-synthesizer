module test_pwm;

reg clk;
reg reset;
reg signed [32:0] audio_in;
wire pwm_out;
wire [9:0] debug_threshold;
wire debug_counter_eq_zero;

// Тактовый генератор 100 МГц
initial clk = 0;
always #5 clk = ~clk;

// Генерация тестового сигнала (синус)
reg signed [32:0] sine_test;
reg [31:0] phase;

initial begin
    reset = 1;
    audio_in = 0;
    phase = 0;
    #100 reset = 0;
    
    forever begin
        // Генерация синуса с частотой 1 кГц
        // 100 МГц / 1000 = 100000 тактов на период
        // phase_inc = 2^32 / 100000 ? 42950
        phase <= phase + 32'd42950;
        sine_test <= $signed(phase[31:22]) - 512;  // -512..511
        audio_in <= sine_test;
        #10;
    end
end

audio_pwm #(
    .INPUT_WIDTH(33),
    .PWM_RESOLUTION(10)
) pwm_inst (
    .clk(clk),
    .reset(reset),
    .audio_in(audio_in),
    .pwm_out(pwm_out),
    .debug_threshold(debug_threshold),
    .debug_counter_eq_zero(debug_counter_eq_zero)
);

// Мониторинг
initial begin
    $dumpfile("pwm_test.vcd");
    $dumpvars(0, test_pwm);
    
    #10000000;  // 10 мс симуляции
    $finish;
end

// Вывод в консоль
always @(posedge clk) begin
    if (debug_counter_eq_zero) begin
        $display("Time=%t, audio_in=%d, threshold=%d", 
                 $time, audio_in, debug_threshold);
    end
end

endmodule