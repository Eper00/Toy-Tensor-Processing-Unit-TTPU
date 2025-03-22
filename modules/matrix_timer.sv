module matrix_timer(
    input wire clk,
    input wire en,
    input wire [15:0] matrix_in [0:31][0:31],
    output reg [15:0] vector_out [0:31]
);

    reg [5:0] step; // Lépésszámláló
    integer i, j;

    always @(posedge clk) begin
        if (en) begin
            // Nullázzuk a vektort minden ciklusban
            for (i = 0; i < 32; i = i + 1) begin
                vector_out[i] <= 16'd0;
            end

            // Ha még nem léptük túl a 62-t, töltsük fel az aktuális átlót
            if (step < 63) begin
                for (i = 0; i <= step; i = i + 1) begin
                    j = step - i;
                    if (i < 32 && j < 32) begin
                        vector_out[i] <= matrix_in[i][j];
                    end
                end
                step <= step + 1; // Következő lépés
            end
        end else begin
            step <= 0; // Reseteljük a számlálót, ha az `en` nincs aktív állapotban
        end
    end

endmodule
