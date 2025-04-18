module systolic_array #(
    parameter WIDTH = 16,
    parameter NUM_UNITS = 16
)(
    input  logic clk,
    input  logic reset,
    input  logic start,

    input  logic [NUM_UNITS-1:0] active_units,
    
    input  logic [NUM_UNITS-1:0][WIDTH-1:0] a_in_array,
    input  logic [NUM_UNITS-1:0][WIDTH-1:0] b_in_array,

    output logic [NUM_UNITS-1:0][WIDTH-1:0] result_array,
    output logic [NUM_UNITS-1:0] ready_array
);

    genvar i;
    generate
        for (i = 0; i < NUM_UNITS; i++) begin : processing_unit_array
            logic pu_start;
            assign pu_start = start & active_units[i];

            processing_unit  pu_inst (
                .clk(clk),
                .reset(reset),
                .start(pu_start),
                .a(active_units[i] ? a_in_array[i] : '0),
                .b(active_units[i] ? b_in_array[i] : '0),
                .P(result_array[i]),
                .ready(ready_array[i])
            );
        end
    endgenerate

endmodule
