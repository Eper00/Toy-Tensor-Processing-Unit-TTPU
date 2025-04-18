module tb_processing_unit();

    reg clk;
    reg reset;
    reg en;
    reg [15:0] a, b;
    wire [15:0] P;
    wire ready;

    // Regisztertömbök
    reg [15:0] a_array [0:3];
    reg [15:0] b_array [0:3];
    integer i;

    // Ready számláló
    integer ready_count = 0;
    integer ready_limit = 3;  // Itt állítható, hány ciklus után álljon meg

    // Unit instanciálása
    processing_unit uut (
        .clk(clk),
        .reset(reset),
        .start(en),
        .a(a),
        .b(b),
        .P(P),
        .ready(ready)
    );

    // Órajel generálás
    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 0;
        en = 0;

        // Adatok betöltése a tömbökbe
        a_array[0] = 16'h4200;
        b_array[0] = 16'hB400;

        a_array[1] = 16'h3400;
        b_array[1] = 16'h4400;

        a_array[2] = 16'h4500;
        b_array[2] = 16'h3000;

        a_array[3] = 16'h3800;
        b_array[3] = 16'h3C00;

        // Reset szekvencia
        #2 reset = 1;
        #10 reset = 0;

        // Engedélyezés
        en = 1;
        i = 0;

        fork
            begin
                while (ready_count < ready_limit) begin
                    @(posedge clk);
                    if (ready) begin
                        a <= a_array[i];
                        b <= b_array[i];
                        i = i + 1;
                        ready_count = ready_count + 1;
                    end
                end
                // Ha elérte a limite, akkor tartjuk az utolsó értékeket
                @(posedge clk);
                en <= 0;  // kikapcsoljuk a start jelet
                $display("Ready pulse count elérte a %0d-et. A bemenetek tartva.", ready_limit);
            end
        join
    end

endmodule
