module tb_picture_pointer_array;

    parameter N_UNITS = 4;

    logic                     clk;
    logic                     rst;
    logic                     step;
    logic [15:0]              start_addr;
    logic [7:0]               kernel_size;
    logic [7:0]               dilation;
    logic [15:0]              width;
    logic [N_UNITS-1:0]       active_units;
    logic [15:0] [N_UNITS-1:0] addr_out;

    picture_pointer_array #(
        .N_UNITS(N_UNITS)
    ) dut (
        .clk(clk),
        .rst(rst),
        .step(step),
        .start_addr(start_addr),
        .kernel_size(kernel_size),
        .dilation(dilation),
        .width(width),
        .active_units(active_units),
        .addr_out(addr_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Helper task: wait for a rising edge
    task tick();
        begin
            #1; step = 1;
            #10; step = 0;
        end
    endtask

    initial begin
        $display("=== picture_pointer_array TEST START ===");
        clk = 0;
        rst = 1;
        step = 0;
        start_addr = 16'd100;
        kernel_size = 8'd3;
        width = 16'd10;
        active_units = 4'b1011;  // Aktív egységek: 0, 1, 3

        // === Eset 1: dilation = 0 ===
        dilation = 8'd0;

        #10 rst = 0;
        #10;

        $display("--- dilation = 0, init values ---");
        foreach (addr_out[i]) begin
            $display("unit[%0d] addr = %0d", i, addr_out[i]);
        end

        tick(); tick(); tick();

        $display("--- after 3 steps (dilation=0) ---");
        foreach (addr_out[i]) begin
            $display("unit[%0d] addr = %0d", i, addr_out[i]);
        end

        // === Eset 2: dilation = 2 ===
        #10;
        rst = 1;
        #10;
        rst = 0;
        dilation = 8'd2;

        #10;
        $display("--- dilation = 2, init values ---");
        foreach (addr_out[i]) begin
            $display("unit[%0d] addr = %0d", i, addr_out[i]);
        end

        tick(); tick(); tick();

        $display("--- after 3 steps (dilation=2) ---");
        foreach (addr_out[i]) begin
            $display("unit[%0d] addr = %0d", i, addr_out[i]);
        end

        $display("=== TEST END ===");
        $finish;
    end

endmodule
