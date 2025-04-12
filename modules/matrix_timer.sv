module matrix_timer(
    input wire clk,
    input wire en,
    input wire [15:0] matrix_in [0:15][0:15],
    output reg [15:0] vector_out [0:15]
);

    reg [7:0] step; // Lépésszámláló
    int i; // ciklusváltozó

    always @(posedge clk) begin
        if (en) begin
            // Nullázzuk a vektort minden ciklusban
            for (i = 0; i < 16; i = i + 1) begin
                vector_out[i] <= 16'd0;
            end

            // Ha még nem léptük túl a 62-t, töltsük fel az aktuális átlót
            if (step < 16*2-1) begin
                for (i = 0; i <= step; i = i + 1) begin
                    integer j_local;
                    j_local = step - {2'b00, i}; 
                    if (i < 16 && j_local < 16) begin
                        vector_out[i] <= matrix_in[i][j_local];
                    end
                end
                step <= step + 1; // Következő lépés
            end
        end else begin
            step <= 0; // Reset
        end
    end

endmodule
