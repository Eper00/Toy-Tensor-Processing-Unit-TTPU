`timescale 1ns/1ps

module tb_vector_adder;

    parameter DATA_WIDTH = 16;
    parameter NUM_UNITS = 4;  // kisebb szám, hogy könnyebb legyen tesztelni

    logic clk, reset, start;
    logic [NUM_UNITS-1:0] active_units;
    logic [DATA_WIDTH-1:0] In_x [NUM_UNITS];
    logic [DATA_WIDTH-1:0] In_bias [NUM_UNITS];
    logic [DATA_WIDTH-1:0] Out [NUM_UNITS];
    logic ready;

    // Órajel
    always #5 clk = ~clk;

    // DUT
    vector_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .In_x(In_x),
        .In_bias(In_bias),
        .Out(Out),
        .ready(ready)
    );

    // Egyszerű lebegőpontos reprezentáció (IEEE 754 half precision, ha 16 bit)
    function logic [15:0] float16(input real r);
        int i;
        shortreal sr;
        sr = r;
        i = $bitstoreal(sr);  // ez trükkös lehet szimulátorfüggően
        float16 = i[15:0];
    endfunction

    initial begin
        $display("=== vector_adder_tb start ===");
        clk = 0;
        reset = 1;
        start = 0;
        active_units = 4'b0000;
        #20;
        
        reset = 0;
        #10;

        // Beállítjuk a bemeneteket
        In_x[0] = 16'h3C00;  // 1.0
        In_bias[0] = 16'h4000;  // 2.0

        In_x[1] = 16'h4000;  // 2.0
        In_bias[1] = 16'h3C00;  // 1.0

        In_x[2] = 16'h0000;  // 0.0
        In_bias[2] = 16'h0000;

        In_x[3] = 16'h3C00;  // 1.0
        In_bias[3] = 16'h3C00;  // 1.0

        // Aktiváljuk csak az 1. és 4. egységet (index 0 és 3)
        active_units = 4'b1001;
        start = 1;
        #10;
        start = 0;

        // Várunk, amíg a ready jel aktív nem lesz
        wait (ready);
        $display("Computation done. Checking outputs...");

        for (int i = 0; i < NUM_UNITS; i++) begin
            $display("Unit %0d => Out: %h", i, Out[i]);
        end

        #20;
        $display("=== vector_adder_tb done ===");
        $finish;
    end

endmodule
