`timescale 1ns / 1ps

module tb_processing_unit;

    // Bemeneti jelek
    logic clk = 0;
    logic reset;
    logic start;
    logic [15:0] a;
    logic [15:0] b;

    // Kimeneti jelek
    logic [15:0] P;
    logic ready;

    // Órajel generálás (10ns periódus)
    always #5 clk = ~clk;

    // DUT (Device Under Test)
    processing_unit dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(a),
        .b(b),
        .P(P),
        .ready(ready)
    );

    initial begin
        $display("Start simulation");
        // Kezdeti állapot
        reset = 1;
        start = 0;
        a = 16'h3C00; // 1.0 (IEEE 754 half)
        b = 16'h4000; // 2.0

        #20;
        reset = 0;

        // Indítunk egy műveletet
        #10;
        start = 1;
        #10;
        start = 0;

        // Várjuk a ready jelet
        wait (ready == 1);
        #10;
        a = 16'h4400; // 4.0 (IEEE 754 half)
        b = 16'h4000; // 2.0
        start = 1;
        #10;
        start = 0;
        wait (ready == 1);
    end

endmodule
