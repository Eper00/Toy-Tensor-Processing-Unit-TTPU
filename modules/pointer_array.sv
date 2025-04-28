module pointer_array #(
    parameter N_UNITS = 16
)(
    input  logic                     clk,
    input  logic                     rst,
    input  logic                     step,
    input  logic        [15:0]       start_addr,
    input  logic        [7:0]        kernel_size,
    input  logic        [N_UNITS-1:0] active_units,
    output logic [N_UNITS-1:0][15:0] addr_out,
    output logic [N_UNITS-1:0][15:0] bias_addr
);

    // Belső címregiszterek
    logic [N_UNITS-1:0][15:0] base_addr;
    logic [N_UNITS-1:0][15:0] current_addr;

    logic [15:0] bias_base_addr;
    logic [7:0]  active_count;
    logic [7:0]  k;

    // Számoljuk az aktív egységeket és bias kezdőcímet
    always_comb begin
        active_count = 0;
        for (int i = 0; i < N_UNITS; i++) begin
            if (active_units[i])
                active_count++;
        end
        bias_base_addr = start_addr + active_count * kernel_size;
    end

    // Inicializálás és léptetés
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            k = 0;
            for (int i = 0; i < N_UNITS; i++) begin
                if (active_units[i]) begin
                    base_addr[i]    <= start_addr + k * kernel_size;
                    current_addr[i] <= start_addr + k * kernel_size;
                    k++;
                end else begin
                    base_addr[i]    <= 16'd0;
                    current_addr[i] <= 16'd0;
                end
            end
        end else if (step) begin
            for (int i = 0; i < N_UNITS; i++) begin
                if (active_units[i]) begin
                    current_addr[i] <= current_addr[i] + 16'd1;
                end
            end
        end
    end

    // Kimenetek frissítése
    always_comb begin
        for (int i = 0; i < N_UNITS; i++) begin
            addr_out[i] = current_addr[i];
            if (active_units[i])
                bias_addr[i] = bias_base_addr + i;
            else
                bias_addr[i] = 16'd0;
        end
    end

endmodule
