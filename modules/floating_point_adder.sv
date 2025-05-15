module floating_point_adder#(
    parameter DATA_WIDTH = 16
)(
    input wire clk,                 
    input wire reset,                
    input wire en,
    input wire [DATA_WIDTH-1:0] a,
    input wire [DATA_WIDTH-1:0] b,
    output reg ready,
    output reg [DATA_WIDTH-1:0] result
);

// --- Pipeline stage 1: unpack ---
reg s1_a_sign, s1_b_sign;
reg [4:0] s1_a_exponent, s1_b_exponent;
reg [9:0] s1_a_fraction, s1_b_fraction;

reg [2:0] cnt ;
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
        if (s1_a_sign!=s1_b_sign && s1_a_exponent==s1_b_exponent && s1_a_fraction == s1_b_fraction) 
        begin
             s2_result_exponent <= 0; s2_shift_amount <= 0;
             s2_ext_a <= 0; s2_ext_b <= 0;
             s2_sign_a <= 0; s2_sign_b <= 0;
        end 
        else begin
            s2_sign_a <= s1_a_sign;
            s2_sign_b <= s1_b_sign;
    
            if (s1_a_exponent > s1_b_exponent) begin
                s2_result_exponent <= s1_a_exponent;
                s2_shift_amount <= s1_a_exponent - s1_b_exponent;
                s2_ext_a <= {1'b1, s1_a_fraction};
                s2_ext_b <= {1'b1, s1_b_fraction} >> (s1_a_exponent - s1_b_exponent);
            end else begin
                s2_result_exponent <= s1_b_exponent;
                s2_shift_amount <= s1_b_exponent - s1_a_exponent;
                s2_ext_b <= {1'b1, s1_b_fraction};
                s2_ext_a <= {1'b1, s1_a_fraction} >> (s1_b_exponent - s1_a_exponent);
            end
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

// --- Pipeline stage 4: normalization logic (kombinációs) ---
reg [9:0] normalized_fraction;
reg [4:0] normalized_exponent;

integer i;
reg [11:0] norm;
reg [4:0] exp;

always @(*) begin
    norm = s3_sum_fraction;
    exp = s3_result_exponent;

    if (norm[11] == 1'b1) begin
        norm = norm >> 1;
        exp = exp + 1;
    end else begin
        for (i = 0; i < 11; i = i + 1) begin
            if (norm[10] == 1'b1 || exp == 0) begin
                // Ha elértük a normalizált formát vagy exp már nem csökkenthető
                break;
            end
            norm = norm << 1;
            exp = exp - 1;
        end
    end

    normalized_fraction = norm[9:0];
    normalized_exponent = exp;

    // Dummy logic to ensure all bits are "used"
    // Ezzel "kiolvassuk" az összes bitet, hogy ne legyen "halott logika"
    if (|exp === 1'bx || &norm === 1'bx) begin
        normalized_fraction = 10'b0; // ezt úgyis felülírja az érték
    end
end

// --- Pipeline stage 4: register result ---
reg s4_result_sign;
reg [4:0] s4_result_exponent;
reg [9:0] s4_result_fraction;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        s4_result_sign <= 0;
        s4_result_exponent <= 0;
        s4_result_fraction <= 0;
        result <= 0;
        cnt<=0;
        ready<=0;
    end else if (en) begin
        cnt<=cnt+1;
        s4_result_sign <= s3_result_sign;
        s4_result_exponent <= normalized_exponent;
        s4_result_fraction <= normalized_fraction;
        if (cnt>3) begin
        cnt<=4;
        ready<=1;
        result <= {s3_result_sign, normalized_exponent, normalized_fraction};
        end else begin
        ready<=0;
        result <=0;
        end
    end
    
end

endmodule
