`timescale 1ns/1ps

module tb_cochlea_auditory_analyzer;

    reg clk;
    reg rst;
    reg start;
    reg sample_valid;
    reg signed [15:0] audio_sample;

    wire [1:0] dominant_channel;

    wire [63:0] energy_250;
    wire [63:0] energy_1000;
    wire [63:0] energy_2500;
    wire [63:0] energy_4500;

    wire done;
    wire busy;

    integer i;
    integer sample_value;
    integer errors;

    real angle;
    real pi;

    // ------------------------------------
    // DUT: Device Under Test
    // ------------------------------------

    cochlea_auditory_analyzer dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .sample_valid(sample_valid),
        .audio_sample(audio_sample),

        .dominant_channel(dominant_channel),

        .energy_250(energy_250),
        .energy_1000(energy_1000),
        .energy_2500(energy_2500),
        .energy_4500(energy_4500),

        .done(done),
        .busy(busy)
    );

    // ------------------------------------
    // CLOCK GENERATION
    // ------------------------------------

    always #5 clk = ~clk;

    // ------------------------------------
    // RESET TASK
    // ------------------------------------

    task reset_dut;
    begin
        @(negedge clk);

        rst = 1;
        start = 0;
        sample_valid = 0;
        audio_sample = 0;

        repeat (3) @(negedge clk);

        rst = 0;

        @(negedge clk);
    end
    endtask

    // ------------------------------------
    // FREQUENCY TEST TASK
    // ------------------------------------

    task run_tone;

        input integer frequency;
        input integer expected_channel;

        begin

            $display("");
            $display("====================================");
            $display("Testing Frequency: %0d Hz", frequency);

            reset_dut();

            // Start analysis

            start = 1;

            @(negedge clk);
            start = 0;

            // Generate 64 sine-wave samples

            for (i = 0; i < 64; i = i + 1) begin

                angle = 2.0 * pi * frequency * i / 16000.0;

                sample_value = $rtoi(10000.0 * $sin(angle));

                @(negedge clk);

                audio_sample = sample_value;
                sample_valid = 1;

                @(negedge clk);

                sample_valid = 0;
                audio_sample = 0;

            end

            // Wait for analysis completion

            wait(done == 1);

            @(negedge clk);

            // Display results

            $display("Input Frequency  : %0d Hz", frequency);
            $display("Expected Channel : %0d", expected_channel);
            $display("Detected Channel : %0d", dominant_channel);

            $display("Energy 250 Hz    : %0d", energy_250);
            $display("Energy 1000 Hz   : %0d", energy_1000);
            $display("Energy 2500 Hz   : %0d", energy_2500);
            $display("Energy 4500 Hz   : %0d", energy_4500);

            // Check result

            if (dominant_channel == expected_channel) begin

                $display("RESULT: PASS");

            end else begin

                $display("RESULT: FAIL");
                errors = errors + 1;

            end

            $display("====================================");

        end

    endtask

    // ------------------------------------
    // MAIN TEST SEQUENCE
    // ------------------------------------

    initial begin

        clk = 0;
        rst = 0;
        start = 0;
        sample_valid = 0;
        audio_sample = 0;

        errors = 0;
        pi = 3.141592653589793;

        reset_dut();

        // Test 1: 250 Hz

        run_tone(250, 0);

        // Test 2: 1000 Hz

        run_tone(1000, 1);

        // Test 3: 2500 Hz

        run_tone(2500, 2);

        // Test 4: 4500 Hz

        run_tone(4500, 3);

        // Final summary

        $display("");
        $display("====================================");

        if (errors == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("TESTS FAILED: %0d", errors);

        $display("====================================");

        $finish;

    end

endmodule
