`timescale 1ns/1ps
module tb_dot_product_multiplication_unit;

    // Paraméterek
    parameter WIDTH = 16;
    parameter NUM_UNITS = 16;

    // Jeldeklarációk
    logic clk;
    logic reset;
    logic start;
    logic [NUM_UNITS-1:0] active_units;
    logic [NUM_UNITS-1:0][WIDTH-1:0] a_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] b_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] bias_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] relu_out;
    logic done;

    // Modult példányosítunk
    dot_product_multiplication_unit #(
        .WIDTH(WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .a_in_array(a_in_array),
        .b_in_array(b_in_array),
        .bias_array(bias_array),
        .relu_out(relu_out),
        .done(done)
    );

    // Órajel generálás
    always begin
        #5 clk = ~clk;  // 100 MHz órajel (10 ns periodus)
    end

    // Tesztben használt inicializálás
    initial begin
        // Kezdeti értékek
        clk = 0;
        reset = 0;
        start = 0;
        active_units = 16'b1111111111111111;  // Minden unit aktív
        a_in_array = '{16'h0010, 16'h0020, 16'h0030, 16'h0040, 16'h0050, 16'h0060, 16'h0070, 16'h0080, 16'h0090, 16'h00A0, 16'h00B0, 16'h00C0, 16'h00D0, 16'h00E0, 16'h00F0, 16'h0100, 16'h0110};
        b_in_array = '{16'h0110, 16'h0100, 16'h00F0, 16'h00E0, 16'h00D0, 16'h00C0, 16'h00B0, 16'h00A0, 16'h0090, 16'h0080, 16'h0070, 16'h0060, 16'h0050, 16'h0040, 16'h0030, 16'h0020, 16'h0010};
        bias_array = '{16'h0001, 16'h0002, 16'h0003, 16'h0004, 16'h0005, 16'h0006, 16'h0007, 16'h0008, 16'h0009, 16'h0010, 16'h0011, 16'h0012, 16'h0013, 16'h0014, 16'h0015, 16'h0016};

        // Reset szekvencia
        reset = 1;
        #10 reset = 0;

        // Indítjuk a műveletet
        start = 1;
        #10 start = 0;

        // Várakozunk a művelet befejezésére
        wait(done == 1);

        // Ellenőrizzük a kimeneti adatokat
        $display("Kimeneti relu_out:");
        for (int i = 0; i < NUM_UNITS; i++) begin
            $display("relu_out[%0d]: %h", i, relu_out[i]);
        end

        // Teszt befejeződik
        $finish;
    end
endmodule
