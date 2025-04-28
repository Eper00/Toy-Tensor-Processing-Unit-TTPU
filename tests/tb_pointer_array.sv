module tb_pointer_array;

    parameter N_UNITS = 4;

    // Tesztjelek
    logic clk;
    logic rst;
    logic step;
    logic [15:0] start_addr;
    logic [7:0] kernel_size;
    logic [N_UNITS-1:0] active_units;
    logic [N_UNITS-1:0][15:0] addr_out;
    logic [N_UNITS-1:0][15:0] bias_addr;

    // DUT
    pointer_array #(.N_UNITS(N_UNITS)) dut (
        .clk(clk),
        .rst(rst),
        .step(step),
        .start_addr(start_addr),
        .kernel_size(kernel_size),
        .active_units(active_units),
        .addr_out(addr_out),
        .bias_addr(bias_addr)
    );

    // Órajelgenerátor
    always #5 clk = ~clk;

    initial begin
        $display("===== Pointer Array Teszt =====");
        clk = 0;
        rst = 1;
        step = 0;
        start_addr = 16'd100;
        kernel_size = 8'd3;
        active_units = 4'b1101;  // aktiv: unit[3], unit[2]=0, unit[1], unit[0]

        // Reset
        #10;
        rst = 0;

        // Lépések indítása
        for (int i = 0; i < 5; i++) begin
            #10;
            step = 1;
            #10;
            step = 0;
            #5;
            $display("Step %0d:", i);
            for (int j = 0; j < N_UNITS; j++) begin
                $display("  Unit %0d -> addr_out: %0d, bias_addr: %0d", j, addr_out[j], bias_addr[j]);
            end
        end

        $finish;
    end

endmodule
