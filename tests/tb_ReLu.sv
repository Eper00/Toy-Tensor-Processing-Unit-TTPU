`timescale 1ns/1ps

module tb_ReLu;

    // Paraméterek
    parameter DATA_WIDTH = 16;
    parameter LENGTH = 64;

    // Tesztjelzők
    reg clk;
    reg reset;
    reg en;
    reg [LENGTH-1:0][DATA_WIDTH-1:0] In;
    wire [0:LENGTH-1][DATA_WIDTH-1:0] Out;

    // DUT (Device Under Test) példányosítása
    ReLu #(
        .DATA_WIDTH(DATA_WIDTH),
        .LENGTH(LENGTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .In(In),
        .Out(Out)
    );

    // Órajel generálása (10ns periódusidő -> 100MHz)
    always #5 clk = ~clk;

    // Tesztelési folyamat
    initial begin
        // Inicializálás
        clk = 0;
        reset = 1;
        en = 0;
        In = '{default: 16'b0};  // minden bemenet 0

        // Specifikus tesztértékek beállítása
        In[0] = 16'b0000_0000_0000_0000;  // 0.0
        In[1] = 16'b0111_1111_1111_1111;  // +32767
        In[2] = 16'b1000_0000_0000_0000;  // -32768
        In[3] = 16'b1111_1111_1111_1111;  // -1

        // Reset aktív
        #10 reset = 0;
        #10 en = 1;

        // Teszt 1: vegyes értékek
        #10;
        $display("T1 - In: %b, %b, %b, %b | Out: %b, %b, %b, %b",
                  In[0], In[1], In[2], In[3], Out[0], Out[1], Out[2], Out[3]);

        // Teszt 2: minden pozitív
        In[0] = 16'b0000_0000_0000_0001;  // +1
        In[1] = 16'b0000_0000_0000_1010;  // +10
        In[2] = 16'b0000_0000_1111_1111;  // +255
        In[3] = 16'b0111_1111_1111_1111;  // +32767
        #10;
        $display("T2 - In: %b, %b, %b, %b | Out: %b, %b, %b, %b",
                  In[0], In[1], In[2], In[3], Out[0], Out[1], Out[2], Out[3]);

        // Teszt 3: minden negatív
        In[0] = 16'b1000_0000_0000_0001;  // -32767
        In[1] = 16'b1111_1111_1111_1110;  // -2
        In[2] = 16'b1111_1111_1111_1111;  // -1
        In[3] = 16'b1000_0000_0000_0000;  // -32768
        #10;
        $display("T3 - In: %b, %b, %b, %b | Out: %b, %b, %b, %b",
                  In[0], In[1], In[2], In[3], Out[0], Out[1], Out[2], Out[3]);

        #10 $finish;
    end

endmodule
