module tb_pointer_array;

    parameter N_UNITS = 4;

    logic clk;
    logic rst;
    logic step;
    logic [31:0] start_addr;
    logic [7:0] kernel_size;
    logic [N_UNITS-1:0] active_units;
    logic [31:0] addr_out [N_UNITS-1:0];
    logic [31:0] bias_addr [N_UNITS-1:0];

    pointer_array #(
        .N_UNITS(N_UNITS)
    ) dut (
        .clk(clk),
        .rst(rst),
        .step(step),
        .start_addr(start_addr),
        .kernel_size(kernel_size),
        .active_units(active_units),
        .addr_out(addr_out),
        .bias_addr(bias_addr)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        rst = 1;
        step = 0;
        start_addr = 32'h1000;
        kernel_size = 8;
        active_units = 4'b1011; // csak az [0], [1] és [3] aktív

        #10;
        rst = 0;

        // Várunk egy kicsit, hogy reset befejeződjön
        #10;

        $display("Initial addresses:");
        for (int i = 0; i < N_UNITS; i++) begin
            $display("Unit %0d -> addr_out = %0h, bias_addr = %0h", i, addr_out[i], bias_addr[i]);
        end

        // Egy step
        step = 1;
        #10;
        step = 0;
        #10;

        $display("After 1 step:");
        for (int i = 0; i < N_UNITS; i++) begin
            $display("Unit %0d -> addr_out = %0h", i, addr_out[i]);
        end

        // Még két step
        repeat (2) begin
            step = 1;
            #10;
            step = 0;
            #10;
        end

        $display("After 3 steps:");
        for (int i = 0; i < N_UNITS; i++) begin
            $display("Unit %0d -> addr_out = %0h", i, addr_out[i]);
        end

        $finish;
    end

endmodule
