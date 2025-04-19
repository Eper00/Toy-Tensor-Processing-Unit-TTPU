module tb_dot_product_multiplication_unit;

    parameter WIDTH = 16;
    parameter NUM_UNITS = 4;

    logic clk, reset, start;
    logic [NUM_UNITS-1:0] active_units;
    logic [$clog2(NUM_UNITS):0] length;

    logic [NUM_UNITS-1:0][WIDTH-1:0] a_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] b_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] bias_array;

    logic [NUM_UNITS-1:0][WIDTH-1:0] relu_out;
    logic done, array_done, data_ready;

    // DUT
    dot_product_multiplication_unit #(
        .WIDTH(WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .length(length),
        .a_in_array(a_in_array),
        .b_in_array(b_in_array),
        .bias_array(bias_array),
        .relu_out(relu_out),
        .done(done),
        .array_done(array_done),
        .data_ready(data_ready)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        active_units = 4'b1111;
        length = 3;

        // Példa értékek: 16 bites lebegőpontos hexák (pl. 0.5, 1.0, -1.0)
        a_in_array = '{16'h3C00, 16'h3C00, 16'hBC00, 16'h0000};  // 1.0, 1.0, -1.0, 0.0
        b_in_array = '{16'h4000, 16'h3C00, 16'h3C00, 16'h0000};  // 2.0, 1.0, 1.0, 0.0
        bias_array  = '{16'h3800, 16'h3800, 16'h3800, 16'h0000}; // 0.5, 0.5, 0.5, 0.0

        #20;
        reset = 0;

        // Start impulzus
        #10;
        start = 1;
        #10;
        start = 0;

        // Várjuk a data_ready jelet
        wait (data_ready);

        // Kiírás
       

        #20;
        $finish;
    end

endmodule
