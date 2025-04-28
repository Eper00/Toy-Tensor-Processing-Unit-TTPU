`timescale 1ns / 1ps

module tb_top_memory;

  parameter DATA_WIDTH = 16;
  parameter IMAGE_WIDTH = 8;
  parameter IMAGE_HEIGHT = 8;
  parameter NUM_UNITS = 2;
  parameter ADDR_WIDTH = $clog2(IMAGE_WIDTH * IMAGE_HEIGHT);

  logic clk;
  logic reset;
  logic step;
  logic en;

  logic [NUM_UNITS-1:0][ADDR_WIDTH-1:0] start_addr_1;
  logic [NUM_UNITS-1:0][ADDR_WIDTH-1:0] start_addr_2;
  logic [NUM_UNITS-1:0][ADDR_WIDTH-1:0] addresses;
  logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim;

  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1;
  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_2;
  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_mem_out;

  // Instantiate the DUT
  top_memory #(
    .DATA_WIDTH(DATA_WIDTH),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .NUM_UNITS(NUM_UNITS)
  ) dut (
    .clk(clk),
    .reset(reset),
    .step(step),
    .en(en),
    .start_addr_1(start_addr_1),
    .start_addr_2(start_addr_2),
    .addresses(addresses),
    .kernel_dim(kernel_dim),
    .out_1(out_1),
    .out_2(out_2),
    .simple_mem_out(simple_mem_out)
  );

  // Clock generator
  always #5 clk = ~clk;

  // Teszt logika
  initial begin
    clk = 0;
    reset = 1;
    en = 0;
    step = 0;

    // Alap bemenetek
    start_addr_1 = '{0, 4};
    start_addr_2 = '{1, 5};
    addresses = '{10, 20};
    kernel_dim = 3;

    // Várj 2 órajelciklust, majd reset le
    #12 reset = 0;

    // Force használata a memóriatömb inicializálásához (belső memória direkt módosítás)
    for (int i = 0; i < IMAGE_WIDTH * IMAGE_HEIGHT; i++) begin
      force dut.simple_memory_array[i] = i * 3;  // példaértékek
    end

    // Aktiváld az engedélyező jelet
    #10 en = 1;

    // Adj néhány lépésjelet
    repeat (5) begin
      #10 step = 1;
      #10 step = 0;
    end

    // Eredmények kiírása
    $display("=== SIMPLE MEM OUTPUT ===");
    for (int i = 0; i < NUM_UNITS; i++) begin
      $display("simple_mem_out[%0d] = %0d", i, simple_mem_out[i]);
    end

    $display("=== OUT_1 ===");
    for (int i = 0; i < NUM_UNITS; i++) begin
      $display("out_1[%0d] = %0d", i, out_1[i]);
    end

    $display("=== OUT_2 ===");
    for (int i = 0; i < NUM_UNITS; i++) begin
      $display("out_2[%0d] = %0d", i, out_2[i]);
    end

    #20 $finish;
  end

endmodule
