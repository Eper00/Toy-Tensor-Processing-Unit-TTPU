module tensor_processing_unit #(
    parameter DATA_WIDTH = 16,
    parameter IMAGE_WIDTH = 5,
    parameter IMAGE_HEIGHT = 5,
    parameter NUM_UNITS = 2
)(
    input  logic clk,
    input  logic reset,
    input  logic en,

    input  logic read_mem1,
    input  logic write_mem1,
    input  logic read_mem2,
    input  logic write_mem2,

    input  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_1,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_2,

    input  logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim,

    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] simple_addr,
    input  logic simple_write,
    input  logic simple_read,



    // Feldolgozás vezérlés
    input  logic start,
    input  logic [NUM_UNITS-1:0] active_units,
    input  logic [($clog2(IMAGE_WIDTH)-1) * ($clog2(IMAGE_WIDTH)-1):0] length,

    // Eredmény és kész jel
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out,
    output logic done,
    output logic mem_en1,
    output logic mem_en2
);

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_2;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_mem_out;
    logic [NUM_UNITS-1:0] array_done;

top_memory #(
    .DATA_WIDTH(DATA_WIDTH),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .NUM_UNITS(NUM_UNITS)
) memory_inst (
    .clk(clk),
    .reset(reset),
    .step(|array_done),
    .en(en),

    .data_in(data_in),
    .read_mem1(read_mem1),
    .write_mem1(write_mem1),
    .start_addr_1(start_addr_1),

    .read_mem2(read_mem2),
    .write_mem2(write_mem2),
    .start_addr_2(start_addr_2),

    .kernel_dim(kernel_dim),

    .simple_write(simple_write),
    .simple_read(simple_read),
    .simple_addr(simple_addr),

    .out_1(out_1),
    .out_2(out_2),
    .simple_mem_out(simple_mem_out),
    .en_out_1(mem_en1),
    .en_out_2(mem_en2)
);

    dot_product_multiplication_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS),
        .IMAGE_WIDTH(IMAGE_WIDTH)
    ) dot_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .length(length),
        .a_in_array(out_1),
        .b_in_array(out_2),
        .bias_array(simple_mem_out),
        .relu_out(relu_out),
        .done(done),
        .array_done(array_done)
    );

endmodule
