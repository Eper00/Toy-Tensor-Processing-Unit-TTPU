module tb_memory_unit;

    parameter DATA_WIDTH = 16;
    parameter IMAGE_WIDTH = 4;
    parameter IMAGE_HEIGHT = 4;
    parameter NUM_UNITS = 2;

    logic clk, reset, step, en, read, write;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in;
    logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] addres_in;
    logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out;
    logic en_out;

    memory_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .step(step),
        .en(en),
        .read(read),
        .write(write),
        .data_in(data_in),
        .addres_in(addres_in),
        .kernel_dim(kernel_dim),
        .out(out),
        .en_out(en_out)
    );

    // Órajel generálása
    always #5 clk = ~clk;

    initial begin
        $display("Start test");
        clk = 0;
        reset = 1;
        step = 0;
        en = 0;
        read = 0;
        write = 0;
        data_in = '{default: 0};
        addres_in = '{default: 0};
        kernel_dim = 2;  // 2x2 kernel

        #10 reset = 0;

        // Írás engedélyezése
        en = 1;
        write = 1;

        // Több érték írása a memóriába különböző címekre
        data_in[0] = 16'hAAAA;  addres_in[0] = 0;
        data_in[1] = 16'hBBBB;  addres_in[1] = 1;
        #10;

        data_in[0] = 16'hCCCC;  addres_in[0] = 2;
        data_in[1] = 16'hDDDD;  addres_in[1] = 3;
        #10;

        write = 0; // befejezzük az írást

        // Előkészítés olvasáshoz
        read = 1;
        addres_in[0] = 0;  // első egység 0-ról indul
        addres_in[1] = 1;  // második egység 1-ről indul
        step = 0;

        #10; // első olvasási ciklus, megkapjuk a 0 és 1 címről az adatokat
        $display("out[0]=%h out[1]=%h", out[0], out[1]);

        // Step aktiválása - továbblépés (sorfolytonosan)
        repeat (3) begin
            step = 1;
            #10;
            $display("step out[0]=%h out[1]=%h", out[0], out[1]);
        end

        step = 0;
        read = 0;
        en = 0;

        $finish;
    end

endmodule
