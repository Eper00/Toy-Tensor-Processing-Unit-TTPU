`timescale 1ns/1ps

module tb_matrix_timer;

    reg clk;
    reg en;
    reg [15:0] matrix_in [0:31][0:31];
    wire [15:0] vector_out [0:31];

    // Példányosítjuk a tesztelt modult
    matrix_timer uut (
        .clk(clk),
        .en(en),
        .matrix_in(matrix_in),
        .vector_out(vector_out)
    );

    // Órajelgenerálás (50 MHz, azaz 20 ns periódus)
    always #10 clk = ~clk;

    integer i, j;

    initial begin
        // Alapértelmezett kezdőértékek
        clk = 0;
        en = 0;

        // Inicializáljuk a bemeneti mátrixot például egy egyszerű számlálós értékekkel
        for (i = 0; i < 32; i = i + 1) begin
            for (j = 0; j < 32; j = j + 1) begin
                matrix_in[i][j] = i * 32 + j + 1; // Pl.: 1, 2, 3, ... 1024
            end
        end

        // Engedélyezzük a működést
        #20 en = 1;

        // Figyeljük a működést 1000 ns-ig
        #(63*10) $finish;
    end

    // Figyeljük a kimenetet
    always @(posedge clk) begin
        if (en) begin
            $display("Timestep %0t: Vector Out: ", $time);
            for (i = 0; i < 32; i = i + 1) begin
                $write("%d ", vector_out[i]);
            end
            $write("\n");
        end
    end

endmodule
