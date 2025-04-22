module tensor_processing_unit #(
    parameter DATA_WIDTH = 16,
    parameter IMAGE_WIDTH = 8,
    parameter IMAGE_HEIGHT = 8,
    parameter NUM_UNITS = 2
)(
    input  logic clk,
    input  logic reset,
    input  logic start,  // külső start jel
    input  logic [NUM_UNITS-1:0] done_array,  // aktív egységek
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH * IMAGE_HEIGHT)-1:0] start_addr_1,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH * IMAGE_HEIGHT)-1:0] start_addr_2,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH * IMAGE_HEIGHT)-1:0] bias_addr,
    input  logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim,
    input  logic [($clog2(IMAGE_WIDTH)-1) * ($clog2(IMAGE_WIDTH)-1):0] length,

    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out,
    output logic done
);

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] a_array;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] b_array;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] bias_array;
    logic step_signal;
    logic array_done;

    // Top memory példány
    top_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) memory_inst (
        .clk(clk),
        .reset(reset),
        .step(step_signal), // <--- a dot_product array_done jele lesz ide kötve
        .en(|done_array),   // egyszerű engedélyezés: ha bármelyik unit aktív
        .start_addr_1(start_addr_1),
        .start_addr_2(start_addr_2),
        .addresses(bias_addr),
        .kernel_dim(kernel_dim),
        .out_1(a_array),
        .out_2(b_array),
        .simple_mem_out(bias_array)
    );

    // Dot product multiplication unit példány
    dot_product_multiplication_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS),
        .IMAGE_WIDTH(IMAGE_WIDTH)
    ) dot_inst (
        .clk(clk),
        .reset(reset),
        .start(start), // <--- kívülről kapott start
        .active_units(done_array),
        .length(length),
        .a_in_array(a_array),
        .b_in_array(b_array),
        .bias_array(bias_array),
        .relu_out(relu_out),
        .done(done),
        .array_done(array_done)
    );

    // step jel összekötés
    assign step_signal = array_done;

endmodule
