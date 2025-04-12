module tb_processing_unit();

    reg clk;                  // Órajel
    reg reset;                // Reset jel
    reg en;                   // Engedélyezés jel
    reg [15:0] a, b;          // Két bemeneti szám
    wire [15:0] P;            // Kimeneti összeg
    wire ready;               // Kimeneti kész jelzés

    // Processing unit instanciálása
    processing_unit uut (
        .clk(clk),
        .reset(reset),
        .start(en),
        .a(a),
        .b(b),
        .P(P),
        .ready(ready)
    );

    // Órajel generálás
    always begin
        #5 clk = ~clk;  // 10 időegység alatt válik 0-ról 1-re
    end

    // Tesztelés
    initial begin
        // Kezdeti állapotok
        clk = 0;
        reset = 0;
        en = 0;
       

       
        reset = 1;
        #10;
        reset = 0;
        #10;

      
      
        a = 16'h4400;  
        b = 16'h4600;  
        en = 1;
        #80;

       
        a = 16'h4000;  // 1 (mantissa = 1, exponent = 0)
        b = 16'hC400;  // 2 (mantissa = 1, exponent = 1)
        #60;
    end

endmodule
