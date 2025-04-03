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

reg [4:0] a_exponent, b_exponent, result_exponent;
reg [9:0] a_fraction, b_fraction, result_fraction;
reg a_sign, b_sign, result_sign;
reg [21:0] product_fraction; // Szorzás után nagyobb méret kell


always @(posedge clk or posedge reset) begin
    if (reset) begin
        result_exponent <= 0;
        result_fraction <= 0;
        result_sign <= 0;
        product_fraction<=0;

    end else if (en) begin

            // *** SZORZÁS ***
            result_sign = a_sign ^ b_sign;
            result_exponent = a_exponent + b_exponent - 15;
            product_fraction = {1'b1,a_fraction} * {1'b1,b_fraction};
           
            // Normalizálás
            if (product_fraction[21]) begin
                result_fraction = product_fraction[20:11];
                result_exponent = result_exponent + 1;
            end else begin
                result_fraction = product_fraction[19:10];
            end
             if (a==0||b==0)begin
                result_sign=0;
                result_exponent=0; 
                result_fraction=0;
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