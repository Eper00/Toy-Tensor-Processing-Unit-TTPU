module top_memory #(
    parameter DATA_WIDTH = 16,
    parameter IMAGE_WIDTH = 8,
    parameter IMAGE_HEIGHT = 8,
    parameter NUM_UNITS = 2
)(
    input  logic clk,
    input  logic reset,
    input  logic step,
    input  logic en,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_1,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_2,
    input   logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] addresses,
    input  logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim,

    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1,
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_2,
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_mem_out
);

    logic en_out_1;
    logic en_out_2;
    logic [DATA_WIDTH-1:0][IMAGE_WIDTH*IMAGE_HEIGHT-1:0] simple_memory_array;

    // Memory Unit 1
    memory_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) mem1 (
        .clk(clk),
        .reset(reset),
        .step(step),
        .en(en),
        .start_addr(start_addr_1),
        .kernel_dim(kernel_dim),
        .out(out_1),
        .en_out(en_out_1)
    );

    // Memory Unit 2
    memory_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) mem2 (
        .clk(clk),
        .reset(reset),
        .step(step),
        .en(en),
        .start_addr(start_addr_2),
        .kernel_dim(kernel_dim),
        .out(out_2),
        .en_out(en_out_2)
    );

    // Simple memory (just outputs data based on address input)
  

    always_comb begin
        for (int i = 0; i < NUM_UNITS; i++) begin
            simple_mem_out[i] = simple_memory_array[addresses[i]];
        end
    end
endmodule
