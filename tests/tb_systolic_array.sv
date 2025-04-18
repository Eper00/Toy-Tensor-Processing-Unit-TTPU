`timescale 1ns/1ps

module tb_systolic_array;

    parameter WIDTH = 16;
    parameter NUM_UNITS = 4;

    // Jelek
    logic clk = 0;
    logic reset;
    logic start;
    logic [NUM_UNITS-1:0] active_units;
    logic [NUM_UNITS-1:0][WIDTH-1:0] a_in_array, b_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] result_array;
    logic [NUM_UNITS-1:0] ready_array;

    // DUT
    systolic_array #(
        .WIDTH(WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .a_in_array(a_in_array),
        .b_in_array(b_in_array),
        .result_array(result_array),
        .ready_array(ready_array)
    );

    // Órajel
    always #5 clk = ~clk;

    initial begin
        $display("---- Systolic Array Test ----");

        // Inicializálás
        reset = 1;
        #10
        reset = 0;
        
        active_units = 4'b1111;
        
        #10
        start = 1;
        // 1.0 * 2.0, 3.0 * 0.5, -1.0 * 1.0, 0.0 * 2.0
        a_in_array[0] = 16'h3C00; // 1.0
        b_in_array[0] = 16'h4000; // 2.0
        
        
        a_in_array[1] = 16'h4200; // 3.0
        b_in_array[1] = 16'h3800; // 0.5

        a_in_array[2] = 16'hBC00; // -1.0
        b_in_array[2] = 16'h3C00; // 1.0
        
        end
        
endmodule