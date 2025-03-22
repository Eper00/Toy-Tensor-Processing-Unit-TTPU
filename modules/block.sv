module processing_unit (
    input wire clk,                  // Órajel
    input wire reset,                // Reset jel
    input wire en,                   // Engedélyezés jel
    input wire [16-1:0] a,   // Első bemeneti szám
    input wire [16-1:0] b,   // Második bemeneti szám
    output reg [16-1:0] P    // Kimeneti összeg
);

    // Két bemenetet használunk a Floating_point_Unit modulban:
    // Az első bemenet a szorzás eredménye (a * b), a második a korábbi eredmény (P) a hozzáadás végrehajtásához.
    reg [16-1:0] result_temp;  // Ideiglenes tároló a szorzás eredményének
    reg [16-1:0] result_sum;   // Az összeg, amit a Floating_point_Unit végez el (P_temp + P)
    // Floating point unit példányosítása (a szorzás és az összegzés végrehajtása)
    floating_point_unit  multiplier  (
        .clk(clk),
        .reset(reset),
        .en(en),
        .dec(1'b1),
        .a(a),             // Szorzáshoz szükséges bemeneti adat
        .b(b),             // Szorzáshoz szükséges bemeneti adat
        .result(result_temp)  // Szorzás eredménye
    );

    // Az összeg végrehajtása (P_temp + P) egy második Floating_point_Unit példány segítségével
    floating_point_unit  adder (
        .clk(~clk),
        .reset(reset),
        .en(en),
        .dec(1'b0),
        .a(result_temp),     // Az előző szorzás eredménye
        .b(P),                // A korábbi kimenet
        .result(result_sum)   // Az összeg (P_temp + P)
    );

    // Az always blokk végrehajtja a kimenet frissítését
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            P <= 0;  
        end else if (en) begin
            P <= result_sum; 
        end else begin
            P<=P;
        end
    end

endmodule
