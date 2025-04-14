module tb_dot_unit;

    parameter WIDTH = 16;
    parameter MAX_LENGTH = 64;

    // bemenetek
    logic clk;
    logic reset;
    logic start;
    logic [WIDTH-1:0] a_in, b_in;
    logic [$clog2(MAX_LENGTH)-1:0] length;

    // kimenetek
    logic [WIDTH-1:0] result;
    logic done;

    // bemeneti adatok
    logic [WIDTH-1:0] a_array [0:3];
    logic [WIDTH-1:0] b_array [0:3];
    int i;

    // unit instanciálása
    dot_unit #(
        .WIDTH(WIDTH),
        .MAX_LENGTH(MAX_LENGTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a_in(a_in),
        .b_in(b_in),
        .length(length),
        .result(result),
        .done(done)
    );

    // órajel generálás
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // kezdő állapot
        clk = 0;
        reset = 1;
        start = 0;
        a_in = 0;
        b_in = 0;
        length = 4;

        // teszt adatok
        a_array[0] = 16'h4000; // 2.0
        b_array[0] = 16'h4000; // 2.0

        a_array[1] = 16'h3C00; // 1.0
        b_array[1] = 16'h3C00; // 1.0

        a_array[2] = 16'h4200; // 3.0
        b_array[2] = 16'h4000; // 2.0

        a_array[3] = 16'h4400; // 4.0
        b_array[3] = 16'h3C00; // 1.0

        #12 reset = 0;

        // indítás
        i = 0;
        fork
            // adatpárok betöltése
            begin
                wait(!reset);
                @(posedge clk);
                start <= 1;
                a_in <= a_array[i];
                b_in <= b_array[i];
                i++;

                while (!done) begin
                    @(posedge clk);
                    if (uut.pu_ready && i < length) begin
                        a_in <= a_array[i];
                        b_in <= b_array[i];
                        i++;
                    end
                end
            end

            // eredmény figyelése
            begin
                wait(done);
                $display("KÉSZ: Eredmény = %h", result);
                $finish;
            end
        join
    end

endmodule
