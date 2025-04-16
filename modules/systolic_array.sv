module systolic_array #(
    parameter WIDTH = 16,
    parameter MAX_LENGTH = 64,
    parameter NUM_UNITS = 64
)(
    input  logic clk,
    input  logic reset,
    input  logic start,

    input  logic [NUM_UNITS-1:0] active_units,
    
    input  logic [NUM_UNITS-1:0][WIDTH-1:0] a_in_array,
    input  logic [NUM_UNITS-1:0][WIDTH-1:0] b_in_array,
    input  logic [NUM_UNITS-1:0][$clog2(MAX_LENGTH)-1:0] length_array,

    output logic [NUM_UNITS-1:0][WIDTH-1:0] result_array,
    output logic [NUM_UNITS-1:0] done_array
);

    genvar i;
    generate
       for (i = 0; i < NUM_UNITS; i++) begin : dot_unit_array
            dot_unit #(
                .WIDTH(WIDTH),
                .MAX_LENGTH(MAX_LENGTH)
            ) du (
                .clk(clk),
                .reset(reset),
                .start(start & active_units[i]), // csak akkor indul, ha aktív
                .a_in(active_units[i] ? a_in_array[i] : 16'b0),
                .b_in(active_units[i] ? b_in_array[i] : 16'b0),
                .length(active_units[i] ? length_array[i] : 16'b0),
                .result(result_array[i]),
                .done(done_array[i])
            );
        end
    endgenerate

endmodule
