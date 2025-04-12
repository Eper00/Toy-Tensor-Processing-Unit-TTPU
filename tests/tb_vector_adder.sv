`timescale 1ns / 1ps

module tb_vector_adder;

  parameter DATA_WIDTH = 16;
  parameter LENGTH = 16;

  logic clk;
  logic reset;
  logic en;
  logic [DATA_WIDTH-1:0] In_x [0:LENGTH-1];
  logic [DATA_WIDTH-1:0] In_bias [0:LENGTH-1];
  logic [DATA_WIDTH-1:0] Out [0:LENGTH-1];

  // Órajel generálása
  always #5 clk = ~clk;

  // DUT példányosítása
  vector_adder #(
    .DATA_WIDTH(DATA_WIDTH),
    .LENGTH(LENGTH)
  ) dut (
    .clk(clk),
    .reset(reset),
    .en(en),
    .In_x(In_x),
    .In_bias(In_bias),
    .Out(Out)
  );


  initial begin
    clk = 0;
    reset = 1;
    en = 0;
    #10;

    reset = 0;
    en = 1;

    // Példaértékek
    In_x[0] = 16'h4200;;
    In_bias[0] = 16'hC600;
    In_x[1] = 16'h3200;;
    In_bias[1] = 16'h4600;

    // Várakozás feldolgozási időre
    #20;


    $finish;
  end

endmodule
