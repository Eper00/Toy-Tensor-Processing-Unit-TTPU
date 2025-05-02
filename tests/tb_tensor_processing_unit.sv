`timescale 1ns/1ps

module tb_tensor_processing_unit;

    parameter DATA_WIDTH = 16;
    parameter IMAGE_WIDTH = 4;
    parameter IMAGE_HEIGHT = 4;
    parameter NUM_UNITS = 2;

    logic clk = 0;
    logic reset;
    logic en;

    logic read_mem1;
    logic write_mem1;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in_mem1;
    logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_1;

    logic read_mem2;
    logic write_mem2;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in_mem2;
    logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_2;

    logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim;

    logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] simple_write_addr;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_write_data;
    logic simple_write;
    logic simple_read;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_2;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_mem_out;

    logic start;
    logic [NUM_UNITS-1:0] active_units;
    logic [($clog2(IMAGE_WIDTH)-1) * ($clog2(IMAGE_WIDTH)-1):0] length;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out;
    logic done;

    // Órajel
    always #5 clk = ~clk;

    tensor_processing_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .en(en),

        .read_mem1(read_mem1),
        .write_mem1(write_mem1),
        .data_in_mem1(data_in_mem1),
        .start_addr_1(start_addr_1),

        .read_mem2(read_mem2),
        .write_mem2(write_mem2),
        .data_in_mem2(data_in_mem2),
        .start_addr_2(start_addr_2),

        .kernel_dim(kernel_dim),

        .simple_write_addr(simple_write_addr),
        .simple_write_data(simple_write_data),
        .simple_write(simple_write),
        .simple_read(simple_read),

        .out_1(out_1),
        .out_2(out_2),
        .simple_mem_out(simple_mem_out),

        .start(start),
        .active_units(active_units),
        .length(length),

        .relu_out(relu_out),
        .done(done)
    );

    // Inicializálás és teszt
    initial begin
        $display("===== Kezdődik a teszt =====");

        reset = 1;
        en = 1;
        start = 0;
        read_mem1 = 0;
        write_mem1 = 0;
        read_mem2 = 0;
        write_mem2 = 0;
        simple_write = 0;
        simple_read = 0;
        active_units = '1;
        kernel_dim = 2;
        length = 4;

        @(negedge clk);
        reset = 0;

        // Bias feltöltés (pl. 0)
        @(negedge clk);
        simple_write = 1;
        simple_write_addr = '{0, 1};
        simple_write_data = '{0, 0};
        @(negedge clk);
        simple_write = 0;

        // Memória 1 feltöltése (A mátrix)
        write_mem1 = 1;
        data_in_mem1 = '{1, 2};
        start_addr_1 = '{0, 1};
        @(negedge clk);
        write_mem1 = 0;

        // Memória 2 feltöltése (B mátrix)
        write_mem2 = 1;
        data_in_mem2 = '{3, 4};
        start_addr_2 = '{0, 1};
        @(negedge clk);
        write_mem2 = 0;

        // Számítás indítása
        @(negedge clk);
        start = 1;
        @(negedge clk);
        start = 0;

        // Várjuk meg a done-t
        wait(done);
        @(negedge clk);

        $display("RELU kimenetek: %d %d", relu_out[0], relu_out[1]);

        $finish;
    end

endmodule
