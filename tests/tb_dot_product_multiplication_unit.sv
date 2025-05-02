module tb_dot_product_multiplication_unit;

    // Paraméterek
    parameter DATA_WIDTH = 16;
    parameter NUM_UNITS = 4;
    parameter NUM_VECTORS = 9;
    parameter IMAGE_WIDTH = 5;

    // Jelek deklarációja
    logic clk;
    logic reset;
    logic start;
    logic [NUM_UNITS-1:0] active_units;
    logic [($clog2(IMAGE_WIDTH)-1) * ($clog2(IMAGE_WIDTH)-1):0] length;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] a_in_array;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] b_in_array;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] bias_array;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out;
    logic done;
    logic array_done;

    // Típusdefiníció bemeneti vektorokra
    typedef logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] vector_t;
    vector_t input_a_array [NUM_VECTORS-1:0];
    vector_t input_b_array [NUM_VECTORS-1:0];

    // Számláló
    logic [$clog2(NUM_VECTORS)-1:0] i;

    // Modul példányosítása
    dot_product_multiplication_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS),
        .IMAGE_WIDTH(IMAGE_WIDTH)
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

    // Inicializálás
    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        active_units = 4'b1111;
        length = 9;

        // Bemeneti vektorok feltöltése
        input_a_array[0] = '{16'h3C00, 16'h3C00, 16'hBC00, 16'h3C00};
        input_b_array[0] = '{16'h4000, 16'h3C00, 16'h3C00, 16'h3C00};

        input_a_array[1] = '{16'h4000, 16'h4000, 16'h4000, 16'h4000};
        input_b_array[1] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00};

        input_a_array[2] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00};
        input_b_array[2] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00};

        input_a_array[3] = '{16'h4000, 16'h4000, 16'h4000, 16'h4000};
        input_b_array[3] = '{16'h4600, 16'h4600, 16'h4600, 16'h4600};
        
         input_a_array[4] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00};
        input_b_array[4] = '{16'h3C00, 16'h3C00, 16'h3C00, 16'h3C00};
        input_a_array[5] = '{16'h4000, 16'h4000, 16'h4000, 16'h4000};
        input_b_array[5] = '{16'h4600, 16'h4600, 16'h4600, 16'h4600};

        bias_array = '{16'h4940, 16'h3800, 16'h3800, 16'h3800};

        // Reset ciklus
        #10 reset = 0;
        start = 1;
        #10 start = 0;
    end

    // Bemeneti vektorok léptetése
    always_ff @(posedge clk) begin
        if (reset) begin
            i <= 0;
            a_in_array <= input_a_array[0];
            b_in_array <= input_b_array[0];
        end else if (array_done) begin
            i <= i + 1;
            if (i + 1 < NUM_VECTORS) begin
                a_in_array <= input_a_array[i + 1];
                b_in_array <= input_b_array[i + 1];
            end
        end
    end

endmodule
