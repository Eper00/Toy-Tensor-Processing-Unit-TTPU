module floating_point_adder#(
    parameter DATA_WIDTH = 16
)(
    input wire clk,                 
    input wire reset,                
    input wire en,
    input wire [DATA_WIDTH-1:0] a,
    input wire [DATA_WIDTH-1:0] b,
    output reg [DATA_WIDTH-1:0] result
);

// --- Pipeline stage 1: unpack ---
reg s1_a_sign, s1_b_sign;
reg [4:0] s1_a_exponent, s1_b_exponent;
reg [9:0] s1_a_fraction, s1_b_fraction;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        s1_a_sign <= 0; s1_b_sign <= 0;
        s1_a_exponent <= 0; s1_b_exponent <= 0;
        s1_a_fraction <= 0; s1_b_fraction <= 0;
    end else if (en) begin
        s1_a_sign     <= a[15];
        s1_a_exponent <= a[14:10];
        s1_a_fraction <= a[9:0];
        s1_b_sign     <= b[15];
        s1_b_exponent <= b[14:10];
        s1_b_fraction <= b[9:0];
    end
end

// --- Pipeline stage 2: shift ---
reg [4:0] s2_result_exponent, s2_shift_amount;
reg [10:0] s2_ext_a, s2_ext_b;
reg s2_sign_a, s2_sign_b;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        s2_result_exponent <= 0; s2_shift_amount <= 0;
        s2_ext_a <= 0; s2_ext_b <= 0;
        s2_sign_a <= 0; s2_sign_b <= 0;
    end else if (en) begin
        s2_sign_a <= s1_a_sign;
        s2_sign_b <= s1_b_sign;

        if (s1_a_exponent > s1_b_exponent) begin
            s2_result_exponent <= s1_a_exponent;
            s2_shift_amount <= s1_a_exponent - s1_b_exponent;
            s2_ext_a <= {1'b1, s1_a_fraction};
            s2_ext_b <= {1'b1, s1_b_fraction} >> s2_shift_amount;
        end else begin
            s2_result_exponent <= s1_b_exponent;
            s2_shift_amount <= s1_b_exponent - s1_a_exponent;
            s2_ext_b <= {1'b1, s1_b_fraction};
            s2_ext_a <= {1'b1, s1_a_fraction} >> s2_shift_amount;
        end
    end
end

// --- Pipeline stage 3: add/sub + sign ---
reg [11:0] s3_sum_fraction;
reg [4:0]  s3_result_exponent;
reg        s3_result_sign;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        s3_sum_fraction <= 0;
        s3_result_exponent <= 0;
        s3_result_sign <= 0;
    end else if (en) begin
        s3_result_exponent <= s2_result_exponent;

        if (s2_sign_a == s2_sign_b) begin
            s3_sum_fraction <= s2_ext_a + s2_ext_b;
            s3_result_sign <= s2_sign_a;
        end else begin
            if (s2_ext_a > s2_ext_b) begin
                s3_sum_fraction <= s2_ext_a - s2_ext_b;
                s3_result_sign <= s2_sign_a;
            end else begin
                s3_sum_fraction <= s2_ext_b - s2_ext_a;
                s3_result_sign <= s2_sign_b;
            end
        end
    end
end

// --- Pipeline stage 4: normalization + result ---
reg [9:0] s4_result_fraction;
reg [4:0] s4_result_exponent;
reg       s4_result_sign;
reg [11:0] norm = s3_sum_fraction;
reg [4:0] exp = s3_result_exponent;
integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 0;
        norm <= 0;
        exp <= 0;
    end else if (en) begin
        s4_result_sign <= s3_result_sign;
        s4_result_exponent <= s3_result_exponent;
        norm <= s3_sum_fraction;
        exp <= s3_result_exponent;
       
        if (s3_sum_fraction[11] == 1) begin
            s4_result_fraction <= s3_sum_fraction[10:1];
            s4_result_exponent <= s3_result_exponent + 1;
        end else begin
            
            for (i = 0; 10 > i && norm[10] == 0 && exp > 0; i = i + 1) begin
                norm = norm << 1;
                exp  = exp - 1;
            end
            s4_result_fraction <= norm[9:0];
            s4_result_exponent <= exp;
        end

        // Final assembly
        result <= {s4_result_sign, s4_result_exponent, s4_result_fraction};
    end
end

endmodule