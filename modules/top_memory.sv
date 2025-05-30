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

    input  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in,
    input  logic read_mem1,
    input  logic write_mem1,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_1,

    input  logic read_mem2,
    input  logic write_mem2,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr_2,

    input  logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim,

    input  logic simple_write,
    input  logic simple_read,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] simple_addr,


    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1,
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_2,
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_mem_out,
    output logic en_out_1,
    output logic en_out_2
);

    

    // Simple memory array
    logic [IMAGE_WIDTH*IMAGE_HEIGHT-1:0][DATA_WIDTH-1:0] simple_memory_array;


    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in_mem1_internal;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in_mem2_internal;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_write_data_internal;
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
        .read(read_mem1),
        .write(write_mem1),
        .data_in(data_in_mem1_internal),
        .addres_in(start_addr_1),
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
        .read(read_mem2),
        .write(write_mem2),
        .data_in(data_in_mem2_internal),
        .addres_in(start_addr_2),
        .kernel_dim(kernel_dim),
        .out(out_2),
        .en_out(en_out_2)
    );

    // Simple memory write
    always_ff @(posedge clk) begin
        if (simple_write) begin
            for (int i = 0; i < NUM_UNITS; i++) begin
                simple_memory_array[simple_addr[i]] <= simple_write_data_internal[i];
            end
        end
    end

    // Simple memory read
    always_ff @(posedge clk) begin
        if (simple_read) begin
            for (int i = 0; i < NUM_UNITS; i++) begin
                simple_mem_out[i] <= simple_memory_array[simple_addr[i]];
            end
        end
    end
 always_comb begin
        // Alapértelmezetten nullázzuk mindet
        data_in_mem1_internal = '0;
        data_in_mem2_internal = '0;
        simple_write_data_internal = '0;

        if (write_mem1) begin
            data_in_mem1_internal = data_in;
        end
        if (write_mem2) begin
            data_in_mem2_internal = data_in;
        end
        if (simple_write) begin
            simple_write_data_internal = data_in;
        end
    end
endmodule
