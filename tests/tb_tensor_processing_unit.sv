`timescale 1ns / 1ps

module tb_tensor_processing_unit;

    parameter DATA_WIDTH = 16;
    parameter IMAGE_WIDTH = 5;
    parameter IMAGE_HEIGHT = 5;
    parameter NUM_UNITS = 9;

    logic clk;
    logic reset;
    logic start;
    logic [NUM_UNITS-1:0] active_units;
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
        .active_units(active_units),
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
        active_units=9'b111111111;
        clk = 0;
        reset = 1;
        start = 0;
       

        // Memóriatartalom feltöltése (pl. pixelértékek, bias stb.)
        preload_memory();

        start_addr_1 = '{0, 1,2,5,6,7,10,11,12};
        start_addr_2 = '{0, 0,0,0,0,0,0,0,0};
        bias_addr    = '{0, 0,0,0,0,0,0,0,0};

        kernel_dim = 3;
        length=kernel_dim*kernel_dim;
        
        #20
        reset = 0;
        #5
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
        // Kép memória feltöltése (mem1.image_mem)
        logic [15:0] image_data [0:24] = {
            16'h0000, 16'h0000, 16'h3C00, 16'h3C00, 16'h0000,
            16'h0000, 16'h3C00, 16'h0000, 16'h3C00, 16'h0000,
            16'h0000, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
            16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
            16'h0000, 16'h0000, 16'h0000, 16'h3C00, 16'h0000
        };
        
        // Kernel memória feltöltése (mem2.image_mem)
       logic [15:0] kernel_data [0:24] = {
        16'h3C00, 16'h0000, 16'hBC00, 
        16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'hBC00, 
        16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'hBC00, 
        16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 
        16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 
        16'h0000, 16'h0000
    };
        
        // Feltöltés
        for (int i = 0; i < 25; i++) begin
            dut.memory_inst.mem1.image_mem[i] = image_data[i];
            dut.memory_inst.simple_memory_array[i] = 16'h0000; // Bias memória: mindig 0
        end

        for (int i = 0; i < 25; i++) begin
            dut.memory_inst.mem2.image_mem[i] = kernel_data[i];
        end
    end
endtask



endmodule
