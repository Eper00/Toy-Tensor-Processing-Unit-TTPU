module tb_dot_product_multiplication_unit;

    // Paraméterek
    parameter WIDTH = 16;
    parameter NUM_UNITS = 4;
    parameter NUM_VECTORS = 3;

    // Jelek deklarációja
    logic clk;
    logic reset;
    logic start;
    logic [NUM_UNITS-1:0] active_units;
    logic [$clog2(NUM_UNITS):0] length;

    logic [NUM_UNITS-1:0][WIDTH-1:0] a_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] b_in_array;
    logic [NUM_UNITS-1:0][WIDTH-1:0] bias_array;

    logic [NUM_UNITS-1:0][WIDTH-1:0] relu_out;
    logic done;
    logic array_done;

    // Bemeneti vektor tömb
    typedef logic [NUM_UNITS-1:0][WIDTH-1:0] vector_t;
    vector_t input_a_array   [NUM_VECTORS];
    vector_t input_b_array   [NUM_VECTORS];

    // Számláló
    logic [$clog2(NUM_VECTORS):0] i;

    // Modul példányosítása
    dot_product_multiplication_unit #(
        .WIDTH(WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .length(length),
        .a_in_array(a_in_array),
        .b_in_array(b_in_array),
        .bias_array(bias_array),
        .relu_out(relu_out),
        .done(done),
        .array_done(array_done)
    );

    // Órajel generálása
    always #5 clk = ~clk;

    // Teszt inicializálás
    initial begin
        clk = 0;
        reset = 1;
        active_units = 4'b1111;
        length = 4;

        // Bemeneti vektorok feltöltése
        input_a_array[0] = '{16'h3C00, 16'h3C00, 16'hBC00, 16'h3C00}; // 1.0, 1.0, -1.0, 1.0
        input_b_array[0] = '{16'h4000, 16'h3C00, 16'h3C00, 16'h3C00}; // 2.0, 1.0, 1.0, 1.0

        input_a_array[1] = '{16'h4000, 16'h4000, 16'h4000, 16'h4000}; // 2.0
        input_b_array[1] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00}; // 1.0

        input_a_array[2] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00}; // 1.0
        input_b_array[2] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00}; // 1.0

        input_a_array[3] = '{16'h4000, 16'h4000, 16'h4000, 16'h4000}; // 2.0
        input_b_array[3] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00}; // 1.0

        bias_array = '{16'h3800, 16'h3800, 16'h3800, 16'h3800}; // 0.5

        // Reset lefutása után indulunk
        #10 reset = 0;
    end

    integer i;

    always_ff @(posedge clk) begin
        if (reset) begin
            i <= 0;
            a_in_array <= input_a_array[0];
            b_in_array <= input_b_array[0];
            start <= 1;
        end else if (array_done) begin
            i <= i + 1;
            if (i + 1 < NUM_VECTORS) begin
                a_in_array <= input_a_array[i + 1];
                b_in_array <= input_b_array[i + 1];
                start <= 1;
            end else begin
                start <= 0;
            end
        end else begin
            start <= 0;
        end
    end
    endmodule
