module dot_product_memory_controller #(
    parameter DATA_WIDTH = 16,
    parameter NUM_UNITS = 4,
    parameter DEPTH = 16 // hány különböző bemeneti vektor van
)(
    input  logic clk,
    input  logic reset,
    input  logic [NUM_UNITS-1:0] done_array,  // ha egy unit kész, új adatot kap
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] a_in_array,
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] b_in_array,
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] bias_array
);

    // Példa memória: DEPTH darab vektor, mindegyik NUM_UNITS hosszú
    logic [DATA_WIDTH-1:0] a_mem[DEPTH-1:0][NUM_UNITS-1:0];
    logic [DATA_WIDTH-1:0] b_mem[DEPTH-1:0][NUM_UNITS-1:0];
    logic [DATA_WIDTH-1:0] bias_mem[DEPTH-1:0][NUM_UNITS-1:0];

    logic [$clog2(DEPTH)-1:0] read_index[NUM_UNITS-1:0];

    // Inicializálás (szimulációhoz)
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            for (int j = 0; j < NUM_UNITS; j++) begin
                a_mem[i][j] = i + j;
                b_mem[i][j] = i + 2*j;
                bias_mem[i][j] = j;
            end
        end
    end

    // Adatfrissítés done_array alapján
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < NUM_UNITS; i++) begin
                read_index[i] <= 0;
            end
        end else begin
            for (int i = 0; i < NUM_UNITS; i++) begin
                if (done_array[i]) begin
                    if (read_index[i] < DEPTH - 1)
                        read_index[i] <= read_index[i] + 1;
                end
            end
        end
    end

    // Bemenetek frissítése
    always_comb begin
        for (int i = 0; i < NUM_UNITS; i++) begin
            a_in_array[i] = a_mem[read_index[i]][i];
            b_in_array[i] = b_mem[read_index[i]][i];
            bias_array[i] = bias_mem[read_index[i]][i];
        end
    end

endmodule
