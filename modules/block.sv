module processing_unit (
    input wire clk,                  // Órajel
    input wire reset,                // Reset jel
    input wire start,                   // Engedélyezés jel
    input wire [15:0] a,             // Első bemeneti szám
    input wire [15:0] b,             // Második bemeneti szám
    output reg [15:0] P,             // Kimeneti összeg
    output reg ready                 // Jelzi, hogy a P kimenet érvényes
);

    reg [15:0] result_temp;          // Ideiglenes tároló a szorzás eredményének
    reg [15:0] result_sum;           // Az összeg, amit a Floating_point_Unit végez el (P_temp + P)

    // Két ciklusos szorzás
    wire [15:0] mult_result;
    reg en1, en2;
    floating_point_multiplayer multiplier (
        .clk(clk),
        .reset(reset),
        .en(en1),
        .a(a),
        .b(b),
        .result(mult_result)
    );

    // Négy ciklusos összegzés
    wire [15:0] sum_result;
    floating_point_adder adder (
        .clk(clk),
        .reset(reset),
        .en(en2),
        .a(result_temp),   // A szorzás eredménye
        .b(P),              // A korábbi kimenet
        .result(sum_result)
    );

    // 2 ciklusos szorzás (mult_result késleltetése)
    reg [2:0] mult_valid_shift;  // 3 bites shift regiszter a szorzás valid jeleinek tárolására
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result_temp <= 0;
            en1 <= 0;
            mult_valid_shift <= 3'b000; // 3 bitre növelve
        end else if (start) begin
            en1 <= 1;
            mult_valid_shift <= mult_valid_shift + 1;  // Shifteljük a valid jelet
            if (mult_valid_shift == 3'b010) begin  // 2. bit - ekkor érkezik meg a szorzás eredménye
                result_temp <= mult_result; // A szorzás eredménye
            end
        end
    end

    // 4 ciklusos késleltetés az adderhez
    reg [4:0] add_valid_shift;   // 5 bites shift regiszter a késleltetéshez
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result_sum <= 0;
            en2 <= 0;
            P <= 0;
            ready <= 0;
            add_valid_shift <= 5'b00000;  // Shift regiszter 5 bitre növelve
        end else if (mult_valid_shift > 3'b010) begin 
            en2 <= 1; // Multiplier vége után jöhet az adder
            add_valid_shift <= add_valid_shift + 1;  // Shifteljük a valid jelet
            if (add_valid_shift == 5'b10000) begin  // Ha elértük a 4. bitet, akkor a kimenet készen van
                result_sum <= sum_result;
                P <= sum_result;
                ready <= 1;  // Kimenet érvényes
            end else begin
                ready <= 0;
            end
        end
    end

endmodule
