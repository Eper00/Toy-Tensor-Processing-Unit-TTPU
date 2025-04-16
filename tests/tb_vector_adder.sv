module tb_vector_adder;

    // Paraméterek
    localparam DATA_WIDTH = 16;
    localparam NUM_UNITS = 64;

    // Bemenetek
    reg clk;
    reg reset;
    reg start;
    reg [NUM_UNITS-1:0] active_units;
    reg [DATA_WIDTH-1:0] In_x [0:NUM_UNITS-1];
    reg [DATA_WIDTH-1:0] In_bias [0:NUM_UNITS-1];

    // Kimenetek
    wire [DATA_WIDTH-1:0] Out [0:NUM_UNITS-1];
    wire ready;

    // UUT instanciálása
    vector_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .active_units(active_units),
        .In_x(In_x),
        .In_bias(In_bias),
        .Out(Out),
        .ready(ready)
    );

    // Órajel generálása
    always #5 clk = ~clk;

    // Teszt szekvencia
    integer i;
    initial begin
        // Inicializálás
        clk = 0;
        reset = 1;
        start = 0;
        active_units = 16'h000F; // Minden egység aktív

        // Inicializálás: In_x = 1.0, In_bias = 2.0 (mind IEEE 754 16-bit formátumban)
        for (i = 0; i < NUM_UNITS; i = i + 1) begin
            In_x[i]    = 16'h3C00; // 1.0
            In_bias[i] = 16'h4000; // 2.0
        end

        // Reset
        #10 reset = 0;
        #10 start = 1;
        #10 start = 0;

        // Várjunk, amíg a művelet befejeződik (vector_adder ADD_7 -> DONE)
        wait (ready == 1);

       
        $finish;
    end

endmodule
