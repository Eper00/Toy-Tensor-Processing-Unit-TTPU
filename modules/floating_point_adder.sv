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

reg [4:0] a_exponent, b_exponent, result_exponent;
reg [9:0] a_fraction, b_fraction, result_fraction;
reg a_sign, b_sign, result_sign;
reg [4:0] shift_amount; // Maximum exponenskülönbség 31 lehet, ezért 6 bit elég
reg [10:0] extended_a_fraction, extended_b_fraction; // Mantissza + implicit 1 bit + extra hely shifteléshez
reg [11:0] sum_fraction;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        result_exponent <= 0;
        result_fraction <= 0;
        result_sign <= 0;
        extended_a_fraction<= 0;
        extended_a_fraction<= 0;
        sum_fraction<= 0;
        shift_amount<= 0;

    end else if (en) begin
         // *** Összeadás ***
         if (a_exponent > b_exponent) begin
                result_exponent = a_exponent;
                shift_amount = a_exponent - b_exponent;
                extended_a_fraction = {1'b1, a_fraction}; // Mantissza implicit 1-essel
                extended_b_fraction = {1'b1, b_fraction} >> shift_amount; // Shifteljük a kisebb számot
            end else begin
                result_exponent = b_exponent;
                shift_amount = b_exponent - a_exponent;
                extended_b_fraction = {1'b1, b_fraction};
                extended_a_fraction = {1'b1, a_fraction} >> shift_amount;
            end   
             // Ha az előjelek megegyeznek -> ÖSSZEADÁS
            if (a_sign == b_sign) begin
                result_sign = a_sign;
                sum_fraction = extended_a_fraction + extended_b_fraction;
            end  else begin
                if (a==b)begin
                      result_exponent = 0;
                      result_fraction = 0;
                      result_sign = 0;
                 end
                 if (extended_a_fraction > extended_b_fraction) begin
                       sum_fraction = extended_a_fraction - extended_b_fraction;
                       result_sign = a_sign;
                    end else if (extended_a_fraction < extended_b_fraction) begin
                        sum_fraction = extended_b_fraction - extended_a_fraction;
                        result_sign = b_sign;
                    end else begin
                        // Ha a számok egyenlő abszolút értékűek, az eredmény 0
                        sum_fraction = 0;
                        result_sign = 0;
                        result_exponent = 0;
                   end
            end
              if (sum_fraction[11] == 1) begin
                    result_fraction = sum_fraction[11:1];    
                         
                    result_exponent = result_exponent + 1;
                end else begin
                    for (integer i=0; i<10;i=i+1) begin
                         if(sum_fraction[10] == 0 && result_exponent > 0)begin
                            sum_fraction = sum_fraction << 1;
                            result_exponent = result_exponent - 1;
                         end else begin
                            break;
                         end
                    end
                    result_fraction = sum_fraction[10:0];
                end
            
                // Underflow ellenőrzés
                if (result_exponent <= 0) begin
                    result_exponent = 0;
                    result_fraction = 0;
                    result_sign = 0;
                end
            
            
        end
    
 end
 // Bitek szétválasztása
  assign a_sign     = a[15];
  assign a_exponent = a[14:10];
  assign a_fraction = a[9:0]; // Implicit 1-es bit hozzáadása
  assign b_sign     = b[15];
  assign b_exponent = b[14:10];
  assign b_fraction = b[9:0]; // Implicit 1-es bit hozzáadása


assign result = {result_sign, result_exponent, result_fraction};

endmodule