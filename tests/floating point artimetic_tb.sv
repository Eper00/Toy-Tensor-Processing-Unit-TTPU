module tb_Floating_point_Unit;

    // Paraméterek
    parameter DATA_WIDTH = 16;

    // Bemenetek
    reg clk;
    reg reset;
    reg en;
    reg dec;
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;

    // Kimenetek
    wire [DATA_WIDTH-1:0] result;

    // Példányosítás
    floating_point_unit #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .dec(dec),
        .a(a),
        .b(b),
        .result(result)
    );

    // Óra generálása
    always begin
        #5 clk = ~clk;  // 10 ns periodikus órajel
    end

    // Kezdeti értékek
    initial begin
        // Órajel, reset, engedélyek kezdeti beállítása
        clk = 0;
        reset = 0;
        en = 0;
        dec = 0;
        a = 0;
        b = 0;

        // Reset szekvencia
        #10 reset = 1;
        #10 reset = 0;

        // Kivonás tesztelése negatív számokkal
        #10 en = 1;
        dec = 0;  // Kivonás
        // Test Case 1: a = -2, b = -5 (a - b = -2 - (-5) = 3)
        a = 16'h4200;  // 3
        b = 16'hC600;  // -6
        #10;


        // Teszt befejezése
        $stop;
    end



endmodule
