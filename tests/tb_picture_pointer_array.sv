module tb_picture_pointer_array;

  parameter N_UNITS = 4;

  logic               clk;
  logic               rst;
  logic               step;
  logic [31:0]        start_addr;
  logic [7:0]         kernel_size;
  logic [7:0]         dilation;
  logic [15:0]        width;
  logic [N_UNITS-1:0] active_units;
  logic [31:0]        addr_out [N_UNITS-1:0];

  // DUT
  picture_pointer_array #(
    .N_UNITS(N_UNITS)
  ) dut (
    .clk(clk),
    .rst(rst),
    .step(step),
    .start_addr(start_addr),
    .kernel_size(kernel_size),
    .dilation(dilation),
    .width(width),
    .active_units(active_units),
    .addr_out(addr_out)
  );

  // Clock generálása
  always #5 clk = ~clk;

  initial begin
    // Alapértékek
    clk = 0;
    rst = 1;
    step = 0;
    start_addr = 32'd100;
    kernel_size = 4;
    dilation = 1;
    width = 6;
    active_units = 4'b1011;  // aktív: unit 0, 1, 3

    // Reset
    #10 rst = 0;

    // Step 1
    #10 step = 1;
    #10 step = 0;

    // Step 2 (második lépés, lehet átlépés ha kernel_size elérve)
    #10 step = 1;
    #10 step = 0;

    // Step 3
    #10 step = 1;
    #10 step = 0;

    // Kiírás
       #10 step = 1;
    #10 step = 0;
       #10 step = 1;
    #10 step = 0;
       #10 step = 1;
    #10 step = 0;
       #10 step = 1;
    #10 step = 0;

    $finish;
  end

endmodule
