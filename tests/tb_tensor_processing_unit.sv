`timescale 1ns / 1ps

module tb_tensor_processing_unit;

    parameter DATA_WIDTH = 16;
    parameter IMAGE_WIDTH = 8;
    parameter IMAGE_HEIGHT = 8;
    parameter NUM_UNITS = 2;

    logic clk;
    logic reset;
    logic start;
    logic [NUM_UNITS-1:0] done_array;
    logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH * IMAGE_HEIGHT)-1:0] start_addr_1;
    logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH * IMAGE_HEIGHT)-1:0] start_addr_2;
    logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH * IMAGE_HEIGHT)-1:0] bias_addr;
    logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim;
    logic [($clog2(IMAGE_WIDTH)-1) * ($clog2(IMAGE_WIDTH)-1):0] length;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out;
    logic done;

    // Clock generator
    always #5 clk = ~clk;

    // DUT
    tensor_processing_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done_array(done_array),
        .start_addr_1(start_addr_1),
        .start_addr_2(start_addr_2),
        .bias_addr(bias_addr),
        .kernel_dim(kernel_dim),
        .length(length),
        .relu_out(relu_out),
        .done(done)
    );

    initial begin
        $display("=== Tensor Processing Unit Testbench with Memory Preload ===");

        clk = 0;
        reset = 1;
        start = 0;
        done_array = 4'b0011;

        // Memóriatartalom feltöltése (pl. pixelértékek, bias stb.)
        preload_memory();

        start_addr_1 = '{0, 10};
        start_addr_2 = '{1, 11};
        bias_addr    = '{2, 12};

        kernel_dim = 2;
        length=kernel_dim*kernel_dim;
        #20
        reset = 0;
        #10;
        start = 1;
        #10;
        start = 0;

        // Várjuk a kész jelet
        wait (done);
        $display("DONE at time %t", $time);

        // Kimenetek kiírása
        for (int i = 0; i < NUM_UNITS; i++) begin
            $display("ReLU[%0d] = %0d", i, relu_out[i]);
        end

        #20;
        $finish;
    end

    // Memória inicializálás
    task preload_memory;
        begin
            // Egyszerű mintaadatok feltöltése
            for (int i = 0; i < IMAGE_WIDTH * IMAGE_HEIGHT; i++) begin
                dut.memory_inst.mem1.image_mem[i] = i * 2;
                dut.memory_inst.simple_memory_array[i]=i;
                dut.memory_inst.mem2.image_mem[i] = i ; // Példa: 0, 2, 4, ...
            end
            

       end
    endtask

endmodule
