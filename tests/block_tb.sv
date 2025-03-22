module tb_PU;

// Paraméterek
parameter DATA_WIDTH = 16;

// Bemenetek
reg clk;
reg reset;
reg en;
reg [DATA_WIDTH-1:0] a;
reg [DATA_WIDTH-1:0] b;

// Kimenetek
wire [DATA_WIDTH-1:0] P;

// Modul példányosítása
PU #(
    .DATA_WIDTH(DATA_WIDTH)
) uut (
    .clk(clk),
    .reset(reset),
    .en(en),
    .a(a),
    .b(b),
    .P(P)
);

// Órajel generátor
always begin
    #5 clk = ~clk;  // Órajel 10 ns periodussal
end

// Tesztelési szekvencia
initial begin
    // Kezdeti értékek
    clk = 0;
    reset = 0;
    en = 0;
    a = 0;
    b = 0;

    // Reset szekvencia
    reset = 1;
    #10;
    reset = 0;
    #10;
    
    // Engedélyezés és bemenetek állítása
    en = 1;
    
   
    
    a = 16'h4080; // a = 2.25
    b = 16'h4500; // b = 5
    #10;          //result_temp=11.25
    
                    //result_sum=11.25

    // Még egy teszt
    a = 16'h4200; // a = 3
    b = 16'hC100; // b = -2.5
    #10;        //result_temp=-7.5
                 //result_sum=11.25-7.5=3.75

    a = 16'h3C70; // a = 1.11
    b = 16'h25E3; // b = 0.023
    #20         //result_temp=0.02553
                //result_sum=11.25-7.5=3.77553
    // Teszt leállítása
    $finish;
end

endmodule
