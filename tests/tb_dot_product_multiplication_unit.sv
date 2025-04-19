module test_dot_product_multiplication_unit;

    // Paraméterek
    parameter WIDTH = 16;
    parameter NUM_UNITS = 16;
    parameter LENGTH = 4;  // Tesztelt hossz

    // Jeldeklarációk
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

    // DUT
    dot_product_multiplication_unit #(
        .WIDTH(WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
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

    // Órajel generálás
    always begin
        #5 clk = ~clk;  // 100 MHz
    end

    // Teszt inicializálás
    initial begin
        // Kezdeti értékek
        clk = 0;
        reset = 1;
        start = 0;
        active_units = 16'hFFFF;
        length = LENGTH;

        // Bemeneti adatok
        a_in_array = '{
            16'h3C00, 16'h4000, 16'h4040, 16'h4080,
            16'h40A0, 16'h40C0, 16'h40E0, 16'h4100,
            16'h4110, 16'h4120, 16'h4130, 16'h4140,
            16'h4150, 16'h4160, 16'h4170, 16'h4180
        };

        b_in_array = '{default:16'h3C00};  // Minden 1.0
        bias_array = '{default:16'h0000}; // Minden 0.0

        // Reset
        #20 reset = 0;

        // Teszt végrehajtása
        #10 start = 1;  // Elindítjuk az első impulzust
        #10 start = 0;

        // Ellenőrzés, hogy az array_done impulzusokat megszámolja
        #40;
        $display("Test after first systolic_done pulse count: %d", dut.array_done_count);

        // Addig folytatjuk, amíg elérjük a kívánt length-et
        #30;
        $display("Test after second systolic_done pulse count: %d", dut.array_done_count);
        #40;
        $display("Test after third systolic_done pulse count: %d", dut.array_done_count);
        #50;
        $display("Test after fourth systolic_done pulse count: %d", dut.array_done_count);
        
        // Ellenőrizzük, hogy az adder bekapcsolódott a megfelelő impulzus után
        #60;
        if (dut.vector_start) begin
            $display("Vector Adder started correctly after %0d cycles", dut.array_done_count);
        end else begin
            $display("Error: Vector Adder not started as expected");
        end

        // Teszt befejezés
        #50;
        $stop;
    end

endmodule
