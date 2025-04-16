`timescale 1ns / 1ps

module tb_systolic_array;

    parameter WIDTH = 16;
    parameter MAX_LENGTH = 64;
    parameter NUM_UNITS = 64;

    logic clk;
    logic reset;
    logic start;
    logic [NUM_UNITS-1:0] active_units;

    logic [NUM_UNITS-1:0][WIDTH-1:0] a_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] b_in_array;
    logic [NUM_UNITS-1:0][$clog2(MAX_LENGTH)-1:0] length_array;

    logic [NUM_UNITS-1:0][WIDTH-1:0] result_array;
    logic [NUM_UNITS-1:0] done_array;

    // Clock generation
    always #5 clk = ~clk;

    systolic_array #(
        .WIDTH(WIDTH),
        .MAX_LENGTH(MAX_LENGTH),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .a_in_array(a_in_array),
        .b_in_array(b_in_array),
        .length_array(length_array),
        .result_array(result_array),
        .done_array(done_array)
    );

 

    initial begin
        integer i;

        // Inicializálás
        clk = 0;
        reset = 1;
        start = 0;
        active_units = 16'b0000000000001111;  // csak az első 4 aktív

        #10;
        reset = 0;

        // Tesztadatok (pl. minden aktív egységhez: a=3, b=2, length=3)
        for (i = 0; i < NUM_UNITS; i++) begin
            if (i < 4) begin
                a_in_array[i] = 16'h4200; // pl. 3.0 half-float
                b_in_array[i] = 16'h4000; // pl. 2.0 half-float
                length_array[i] = 3;
            end else begin
                a_in_array[i] = '0;
                b_in_array[i] = '0;
                length_array[i] = 0;
            end
        end

        #10;
        start = 1;
        #10;
        start = 0;

        // Várakozás, amíg minden aktív unit done lesz
        wait (&done_array[3:0]);

        $display("Eredmények:");
        for (i = 0; i < NUM_UNITS; i++) begin
            $display("Unit %0d: done=%0b, result=0x%04h", i, done_array[i], result_array[i]);
        end

        #50;
        $finish;
    end

endmodule
