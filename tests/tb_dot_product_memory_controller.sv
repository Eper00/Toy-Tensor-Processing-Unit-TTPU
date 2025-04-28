`timescale 1ns/1ps

module tb_dot_product_memory_controller;

    parameter DATA_WIDTH = 16;
    parameter NUM_UNITS = 4;
    parameter DEPTH = 16;

    logic clk;
    logic reset;
    logic [NUM_UNITS-1:0] done_array;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] a_in_array;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] b_in_array;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] bias_array;

    // Instantiate the DUT
    dot_product_memory_controller #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .done_array(done_array),
        .a_in_array(a_in_array),
        .b_in_array(b_in_array),
        .bias_array(bias_array)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $display("=== DOT PRODUCT MEMORY CONTROLLER TEST ===");
        clk = 0;
        reset = 1;
        done_array = 0;
        #10;

        reset = 0;
        #10;

        repeat (5) begin
            // Aktiválunk néhány done jelet
            done_array = 4'b1010;  // Egység 1 és 3 kap új adatot
            #10;
            $display("Time %0t: A=%p B=%p Bias=%p", $time, a_in_array, b_in_array, bias_array);

            done_array = 4'b0000;  // szünet
            #10;
        end

        // Minden unit egyszerre készen
        done_array = 4'b1111;
        #10;
        $display("Time %0t: A=%p B=%p Bias=%p", $time, a_in_array, b_in_array, bias_array);

        done_array = 0;
        #10;

        repeat (3) begin
            done_array = 4'b0101;
            #10;
            $display("Time %0t: A=%p B=%p Bias=%p", $time, a_in_array, b_in_array, bias_array);
            done_array = 0;
            #10;
        end

        $display("=== TEST END ===");
        $finish;
    end

endmodule
