module tb_systolic_array;

    // Paraméterek
   
    // Jelváltozók
    reg clk;
    reg reset;
    reg en;
    reg [5:0] matrix_N;
    reg [15:0] a [0:32-1];
    reg [15:0] b [0:32-1];
    wire [15:0] P [0:32-1];
    wire ready;

    // Modul instanciálása
    systolic_array uut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .matrix_N(matrix_N),
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
        matrix_N=4;
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
