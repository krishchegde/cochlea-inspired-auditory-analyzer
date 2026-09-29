module cochlea_auditory_analyzer (
    input wire clk,
    input wire rst,
    input wire start,

    input wire sample_valid,
    input wire signed [15:0] audio_sample,

    output reg [1:0] dominant_channel,
    output reg [63:0] energy_250,
    output reg [63:0] energy_1000,
    output reg [63:0] energy_2500,
    output reg [63:0] energy_4500,

    output reg done,
    output reg busy
);

    // ------------------------------------------------
    // PARAMETERS
    // ------------------------------------------------

    parameter N = 64;

    localparam signed [17:0] C0 =  18'sd32610;
    localparam signed [17:0] C1 =  18'sd30274;
    localparam signed [17:0] C2 =  18'sd18205;
    localparam signed [17:0] C3 = -18'sd6393;

    // ------------------------------------------------
    // FSM STATES
    // ------------------------------------------------

    localparam IDLE    = 2'd0;
    localparam CAPTURE = 2'd1;
    localparam CALC    = 2'd2;

    reg [1:0] state;

    reg [5:0] sample_count;

    // ------------------------------------------------
    // GOERTZEL STATE REGISTERS
    // ------------------------------------------------

    reg signed [31:0] s10, s20;
    reg signed [31:0] s11, s21;
    reg signed [31:0] s12, s22;
    reg signed [31:0] s13, s23;

    // ------------------------------------------------
    // COEFFICIENT MULTIPLICATION
    // ------------------------------------------------

    wire signed [49:0] mult0 = C0 * s10;
    wire signed [49:0] mult1 = C1 * s11;
    wire signed [49:0] mult2 = C2 * s12;
    wire signed [49:0] mult3 = C3 * s13;

    wire signed [31:0] term0 = mult0 >>> 14;
    wire signed [31:0] term1 = mult1 >>> 14;
    wire signed [31:0] term2 = mult2 >>> 14;
    wire signed [31:0] term3 = mult3 >>> 14;

    // ------------------------------------------------
    // GOERTZEL RECURRENCE
    // s[n] = x[n] + 2cos(w)*s[n-1] - s[n-2]
    // ------------------------------------------------

    wire signed [31:0] next0 =
        audio_sample + term0 - s20;

    wire signed [31:0] next1 =
        audio_sample + term1 - s21;

    wire signed [31:0] next2 =
        audio_sample + term2 - s22;

    wire signed [31:0] next3 =
        audio_sample + term3 - s23;

    // ------------------------------------------------
    // GOERTZEL POWER FUNCTION
    // ------------------------------------------------

    function [63:0] calc_power;

        input signed [31:0] a;
        input signed [31:0] b;
        input signed [17:0] coeff;

        reg signed [63:0] a_ext;
        reg signed [63:0] b_ext;

        reg signed [63:0] aa;
        reg signed [63:0] bb;
        reg signed [63:0] ab;

        reg signed [81:0] coeff_ext;
        reg signed [81:0] ab_ext;
        reg signed [81:0] coeff_ab;
        reg signed [81:0] total;

        begin

            a_ext = {{32{a[31]}}, a};
            b_ext = {{32{b[31]}}, b};

            aa = a_ext * a_ext;
            bb = b_ext * b_ext;
            ab = a_ext * b_ext;

            coeff_ext = {{64{coeff[17]}}, coeff};
            ab_ext = {{18{ab[63]}}, ab};

            coeff_ab = coeff_ext * ab_ext;

            total =
                $signed({18'b0, aa}) +
                $signed({18'b0, bb}) -
                (coeff_ab >>> 14);

            if (total < 0)
                calc_power = 64'd0;
            else
                calc_power = total[63:0];

        end

    endfunction

    // ------------------------------------------------
    // FREQUENCY ENERGY CALCULATION
    // ------------------------------------------------

    wire [63:0] p0 = calc_power(s10, s20, C0);
    wire [63:0] p1 = calc_power(s11, s21, C1);
    wire [63:0] p2 = calc_power(s12, s22, C2);
    wire [63:0] p3 = calc_power(s13, s23, C3);

    // ------------------------------------------------
    // MAIN FSM
    // ------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            state <= IDLE;
            sample_count <= 0;

            s10 <= 0;
            s20 <= 0;

            s11 <= 0;
            s21 <= 0;

            s12 <= 0;
            s22 <= 0;

            s13 <= 0;
            s23 <= 0;

            dominant_channel <= 0;

            energy_250 <= 0;
            energy_1000 <= 0;
            energy_2500 <= 0;
            energy_4500 <= 0;

            done <= 0;
            busy <= 0;

        end else begin

            done <= 0;

            case (state)

                // ------------------------------------
                // IDLE
                // ------------------------------------

                IDLE: begin

                    busy <= 0;

                    if (start) begin

                        state <= CAPTURE;
                        sample_count <= 0;

                        s10 <= 0;
                        s20 <= 0;

                        s11 <= 0;
                        s21 <= 0;

                        s12 <= 0;
                        s22 <= 0;

                        s13 <= 0;
                        s23 <= 0;

                        busy <= 1;

                    end

                end

                // ------------------------------------
                // CAPTURE AUDIO SAMPLES
                // ------------------------------------

                CAPTURE: begin

                    if (sample_valid) begin

                        s10 <= next0;
                        s20 <= s10;

                        s11 <= next1;
                        s21 <= s11;

                        s12 <= next2;
                        s22 <= s12;

                        s13 <= next3;
                        s23 <= s13;

                        if (sample_count == N-1) begin
                            state <= CALC;
                        end else begin
                            sample_count <= sample_count + 1'b1;
                        end

                    end

                end

                // ------------------------------------
                // CALCULATE ENERGY AND SELECT CHANNEL
                // ------------------------------------

                CALC: begin

                    energy_250 <= p0;
                    energy_1000 <= p1;
                    energy_2500 <= p2;
                    energy_4500 <= p3;

                    if (p0 >= p1 && p0 >= p2 && p0 >= p3)
                        dominant_channel <= 2'd0;

                    else if (p1 >= p0 && p1 >= p2 && p1 >= p3)
                        dominant_channel <= 2'd1;

                    else if (p2 >= p0 && p2 >= p1 && p2 >= p3)
                        dominant_channel <= 2'd2;

                    else
                        dominant_channel <= 2'd3;

                    done <= 1;
                    busy <= 0;
                    state <= IDLE;

                end

                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end

endmodule
