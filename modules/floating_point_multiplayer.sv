module floating_point_multiplayer#(
    parameter DATA_WIDTH = 16
)(
    input wire clk,                 
    input wire reset,                
    input wire en,
    input wire [DATA_WIDTH-1:0] a,
    input wire [DATA_WIDTH-1:0] b,
    output reg [DATA_WIDTH-1:0] result
);

// --- Stage 1: unpack + multiply ---
reg s1_sign_a, s1_sign_b;
reg [4:0] s1_exp_a, s1_exp_b;
reg [9:0] s1_frac_a, s1_frac_b;

reg s1_result_sign;
reg [4:0] s1_result_exponent;
reg [21:0] s1_product_fraction;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        s1_sign_a <= 0; s1_sign_b <= 0;
        s1_exp_a <= 0; s1_exp_b <= 0;
        s1_frac_a <= 0; s1_frac_b <= 0;
        s1_result_sign <= 0;
        s1_result_exponent <= 0;
        s1_product_fraction <= 0;
    end else if (en) begin
        s1_sign_a <= a[15];
        s1_exp_a  <= a[14:10];
        s1_frac_a <= a[9:0];
        s1_sign_b <= b[15];
        s1_exp_b  <= b[14:10];
        s1_frac_b <= b[9:0];

        s1_result_sign <= a[15] ^ b[15];
        s1_result_exponent <= a[14:10] + b[14:10] - 15;
        s1_product_fraction <= {1'b1, a[9:0]} * {1'b1, b[9:0]};
    end
end

// --- Stage 2: normalization + result ---
reg [9:0] s2_result_fraction;
reg [4:0] s2_result_exponent;
reg s2_result_sign;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 0;
    end else if (en) begin
        if (a == 0 || b == 0) begin
            result <= 0;
        end else begin
            if (s1_product_fraction[21] == 1'b1) begin
                s2_result_fraction <= s1_product_fraction[20:11];
                s2_result_exponent <= s1_result_exponent + 1;
            end else begin
                s2_result_fraction <= s1_product_fraction[19:10];
                s2_result_exponent <= s1_result_exponent;
            end

            s2_result_sign <= s1_result_sign;

            result <= {s2_result_sign, s2_result_exponent, s2_result_fraction};
        end
    end
end

endmodule
