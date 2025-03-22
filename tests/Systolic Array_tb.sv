module systolic_array_tb;

    // Paraméterek
    parameter L = 4;

    // Jelváltozók
    reg clk;
    reg reset;
    reg en;
    reg [15:0] a [0:L-1];
    reg [15:0] b [0:L-1];
    wire [15:0] P [0:L-1];
    wire ready;

    // Modul instanciálása
    systolic_array #(L) uut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .a(a),
        .b(b),
        .P(P),
        .ready(ready)
    );

    // Órajel generálása
    always begin
        #5 clk = ~clk; // 10 ns per period
    end

    // Kezdő logika
    initial begin
        // Kezdeti értékek beállítása
        clk = 0;
        reset = 1;
        en = 1;
        #10
        reset = 0;
        // Bemeneti adatok inicializálása
        a[0]=16'h3C00;
        a[1]=16'h0000;
        a[2]=16'h0000;
        a[3]=16'h0000;
        
        b[0]=16'h3C00;
        b[1]=16'h4000;
        b[2]=16'h4400;
        b[3]=16'h4C00;
        
       
        #10
        a[0]=16'h3C00;
        a[1]=16'h3C00;
        a[2]=16'h0000;
        a[3]=16'h0000;
        #10
        a[0]=16'h3C00;
        a[1]=16'h3C00;
        a[2]=16'h3C00;
        a[3]=16'h0000;
        #10
        a[0]=16'h3C00;
        a[1]=16'h3C00;
        a[2]=16'h3C00;
        a[3]=16'h4000;
        #10
        a[0]=16'h0000;
        a[1]=16'h3C00;
        a[2]=16'h3C00;
        a[3]=16'h4000;
        #10
        a[0]=16'h0000;
        a[1]=16'h0000;
        a[2]=16'h3C00;
        a[3]=16'h4000;
        #10
        a[0]=16'h0000;
        a[1]=16'h0000;
        a[2]=16'h0000;
        a[3]=16'h4000;
        #10
        a[0]=16'h0000;
        a[1]=16'h0000;
        a[2]=16'h0000;
        a[3]=16'h0000;
        #10
        a[0]=16'h0000;
        a[1]=16'h3C00;
        a[2]=16'h0000;
        a[3]=16'h0000;
        #10
        // Teszt: Engedélyezés és működés
        $display("Test: Enable active...");
        en = 1;
        #10;
       
       

        // Teszt vége
        $finish;
    end

    

endmodule
