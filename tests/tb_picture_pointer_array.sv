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
    logic [N_UNITS-1:0][15:0] addr_out;

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

    // Órajel generálás
    always #5 clk = ~clk;

    initial begin
        $display("==== picture_pointer_array TEST START ====");
        $monitor("Time %0t | dilation=%0d | step=%b | addr_out = %p",
                 $time, dilation, step, addr_out);

        // Inicializálás
        clk          = 0;
        rst          = 1;
        step         = 0;
        start_addr   = 16'd100;
        kernel_size  = 8'd3;
        dilation     = 8'd0;   // Először dilation = 0
        width        = 16'd10;
        active_units = 4'b1011;

        #10;
        rst = 0;

        // Lépések dilation = 0 esetén
        repeat (5) begin
            #10;
            step = 1;
            #10;
            step = 0;
        end

        // dilation = 2 eset
        #20;
        rst = 1;
        #10;
        rst = 0;
        dilation = 8'd2;

        repeat (5) begin
            #10;
            step = 1;
            #10;
            step = 0;
        end

        #20;
        $display("==== picture_pointer_array TEST END ====");
        $finish;
    end

endmodule
