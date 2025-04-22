module tb_memory_unit;

    // Paraméterek
    localparam DATA_WIDTH = 16;
    localparam IMAGE_WIDTH = 8;
    localparam IMAGE_HEIGHT = 8;
    localparam NUM_UNITS = 2;

    // Jelölők
    logic clk;
    logic reset;
    logic step;
    logic en;
    logic [NUM_UNITS-1:0][($clog2(IMAGE_WIDTH*IMAGE_HEIGHT))-1:0] start_addr;
    logic [($clog2(IMAGE_WIDTH))-1:0] kernel_dim;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out;
    logic en_out;

    // Modul instanciálása
    memory_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .step(step),
        .en(en),
        .start_addr(start_addr),
        .kernel_dim(kernel_dim),
        .out(out),
        .en_out(en_out)
    );

    // Órajel generálás
    always begin
        #5 clk = ~clk; // 10 időegység frekvenciával
    end

    // Tesztelési folyamat
    initial begin
         // Memória adatok inicializálása (példa értékek)
        for (integer i = 0; i < IMAGE_WIDTH*IMAGE_HEIGHT; i = i + 1) begin
            uut.image_mem[i] = i; // Példa: minden memóriaelem a címének megfelelő értéket kap
        end
        clk = 0;
        reset = 0;
        step = 0;
        en = 0;
        start_addr[0] = 0; // Az első unit kezdőcíme
        start_addr[1] = 1; // A második unit kezdőcíme
        kernel_dim = 2; // Kernel dimenzió
        // Az image_mem inicializálásának ellenőrzése a memóriában

        // Resetelés
        $display("Kezdő reset...");
        reset = 1;
        #10;
        reset = 0;
        en = 1;
         #20;
        // Engedélyezés és léptetés tesztelése
        $display("Tesztelés elindítása...");
        
       
        // Várakozás a memória kimenet frissítésére
        

        // Ellenőrzés a kimeneteken
        $display("Kimenetek:");
        $display("Out[0] = %0d", out[0]);
        $display("Out[1] = %0d", out[1]);

        // Végrehajtjuk még pár lépést
        #5;
        step = 1;
        #5;
        step = 0;
        #5;
        step = 1;
        #5;
         step = 0;
        #5;
        step = 1;
        #5;
         step = 0;
        #5;
        step = 1;
        #5;
         step = 0;
        #5;
        step = 1;
        #5;
         step = 0;
        #5;
        step = 1;
        #5;
          step = 0;
        #5;
        step = 1;
        #5;
          step = 0;
        #5;
        step = 1;
        #5;

        // Tesztelés vége
        $display("Teszt vége.");
        $finish;
    end

endmodule
