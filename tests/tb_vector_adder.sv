`timescale 1ns/1ps

module tb_vector_adder;

    parameter DATA_WIDTH = 16;
    parameter NUM_UNITS = 4;  // kisebb szám, hogy könnyebb legyen tesztelni

    logic clk, reset, start;
    logic [NUM_UNITS-1:0] active_units;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] In_x;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] In_bias;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] Out;
    logic ready;

    // Órajel generálás
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

    // (Opcionális) IEEE 754 half-precision float konverzió
    // Itt csak statikus értékek vannak, úgyhogy nem használjuk ezt most

    initial begin
        $display("=== vector_adder_tb start ===");
        clk = 0;
        reset = 1;
        start = 0;
        active_units = 4'b0000;
        #20;

        reset = 0;
        #10;

        // Bemenetek beállítása (hex értékek)
        In_x[0] = 16'h3C00;     // 1.0
        In_bias[0] = 16'h4000;  // 2.0

        In_x[1] = 16'h4000;     // 2.0
        In_bias[1] = 16'h3C00;  // 1.0

        In_x[2] = 16'h0000;     // 0.0
        In_bias[2] = 16'h0000;  // 0.0

        In_x[3] = 16'h3C00;     // 1.0
        In_bias[3] = 16'h3C00;  // 1.0

        // Csak az 1. és 4. egységet aktiváljuk
        active_units = 4'b1001;

        start = 1;
        #10;
        start = 0;

        // Várunk, amíg a ready jel fel nem megy
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
