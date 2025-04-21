module picture_pointer_array #(
    parameter N_UNITS = 16
)(
    input  logic               clk,
    input  logic               rst,
    input  logic               step,
    input  logic [16:0]        start_addr,
    input  logic [7:0]         kernel_size,
    input  logic [7:0]         dilation,
    input  logic [15:0]        width,
    input  logic [N_UNITS-1:0] active_units,
    output logic [16:0]       [N_UNITS-1:0] addr_out 
);

    logic [31:0] [N_UNITS-1:0]base_addr;
    logic [31:0] [N_UNITS-1:0]current_addr;
    logic [7:0]  k;

    // Inicializálás resetnél
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            k = 0;
            for (int i = 0; i < N_UNITS; i++) begin
                if (active_units[i]) begin
                    if (dilation == 0) begin
                        base_addr[i]    <= start_addr;
                        current_addr[i] <= start_addr;
                    end else begin
                        base_addr[i]    <= start_addr + k * kernel_size * dilation;
                        current_addr[i] <= start_addr + k * kernel_size * dilation;
                        k++;
                    end
                end else begin
                    base_addr[i]    <= 32'd0;
                    current_addr[i] <= 32'd0;
                end
            end
        end else if (step) begin
            for (int i = 0; i < N_UNITS; i++) begin
                if (active_units[i]) begin
                    if (dilation == 0) begin
                        current_addr[i] <= current_addr[i] + 1;
                    end else begin
                        if ((current_addr[i] - base_addr[i]) >= kernel_size)
                            current_addr[i] <= current_addr[i] + (width - kernel_size);
                        else
                            current_addr[i] <= current_addr[i] + dilation;
                    end
                end
            end
        end
    end

    // Címek kimenete
    always_comb begin
        for (int i = 0; i < N_UNITS; i++) begin
            addr_out[i] = current_addr[i];
        end
    end

endmodule
