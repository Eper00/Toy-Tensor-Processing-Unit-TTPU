module tb_floating_point_multiplayer;

    // Paraméterek
    parameter DATA_WIDTH = 16;

    // Bemenetek
    reg clk;
    reg reset;
    reg en;
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;

    // Kimenetek
    wire [DATA_WIDTH-1:0] result;

    // Példányosítás
    floating_point_multiplayer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .en(en),
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
        a = 0;
        b = 0;

        // Reset szekvencia
        #10 reset = 1;
        #10 reset = 0;

       
        #10 en = 1;
       
        a = 16'habcd;  // 3
        b = 16'h4CA2;  // -6
        #10;


        // Teszt befejezése
        $stop;
    end



endmodule