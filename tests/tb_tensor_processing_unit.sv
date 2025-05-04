module tb_tensor_processing_unit;

    parameter DATA_WIDTH = 16;
    parameter IMAGE_WIDTH = 5;
    parameter IMAGE_HEIGHT = 5;
    parameter NUM_UNITS = 9;
    parameter MEM_SIZE = IMAGE_WIDTH * IMAGE_HEIGHT;

    logic clk, reset, en;
    logic read_mem1, write_mem1, read_mem2, write_mem2;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in_mem1, data_in_mem2;
    logic [NUM_UNITS-1:0][$clog2(MEM_SIZE)-1:0] start_addr_1, start_addr_2;
    logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim;
    logic [NUM_UNITS-1:0][$clog2(MEM_SIZE)-1:0] simple_write_addr;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] simple_write_data;
    logic simple_write, simple_read;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out_1, out_2, simple_mem_out;
    logic start;
    logic [NUM_UNITS-1:0] active_units;
    logic [($clog2(IMAGE_WIDTH)-1)*($clog2(IMAGE_WIDTH)-1):0] length;
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out;
    logic done;

    // Instantiate TPU
    tensor_processing_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .NUM_UNITS(NUM_UNITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .read_mem1(read_mem1),
        .write_mem1(write_mem1),
        .data_in_mem1(data_in_mem1),
        .start_addr_1(start_addr_1),
        .read_mem2(read_mem2),
        .write_mem2(write_mem2),
        .data_in_mem2(data_in_mem2),
        .start_addr_2(start_addr_2),
        .kernel_dim(kernel_dim),
        .simple_write_addr(simple_write_addr),
        .simple_write_data(simple_write_data),
        .simple_write(simple_write),
        .simple_read(simple_read),
        .out_1(out_1),
        .out_2(out_2),
        .simple_mem_out(simple_mem_out),
        .start(start),
        .active_units(active_units),
        .length(length),
        .relu_out(relu_out),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Memory data
    logic [15:0] mem1_data [0:24] = '{
        16'h0000, 16'h0000, 16'h3C00, 16'h3C00, 16'h0000,
        16'h0000, 16'h3C00, 16'h0000, 16'h3C00, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h3C00, 16'h0000,
        16'h0000, 16'h0000, 16'h3C00, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h3C00, 16'h0000
    };

    logic [15:0] mem2_data [0:24] = '{
        16'h3C00, 16'h0000, 16'hBC00, 16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'hBC00, 16'h0000, 16'h0000,
        16'h3C00, 16'h0000, 16'hBC00, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000
    };
    logic [15:0] simple_mem_data [0:24] = '{
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000,
        16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000
     };
    // Write routine
    task write_memory;
        integer i, j;
        for (i = 0; i < MEM_SIZE; i += NUM_UNITS) begin
            @(posedge clk);
             
            for (j = 0; j < NUM_UNITS; j++) begin
                
      
                
                if (i + j < MEM_SIZE) begin
                    data_in_mem1[j] <= mem1_data[i + j];
                    start_addr_1[j] <= i + j;
                   
                    data_in_mem2[j] <= mem2_data[i + j];
                    start_addr_2[j] <= i + j;
                    
                    simple_write_addr[j]<=i+j;
                    simple_write_data[j]<=simple_mem_data[i+j];
                   
                    
                   
                end 
            end

         
        end
      
                   
    endtask

    // Initial block
    initial begin
        clk = 0;
        reset = 1;
        en = 1;
        write_mem1 = 0;
        write_mem2 = 0;
        read_mem1 = 0;
        read_mem2 = 0;
        simple_write = 0;
        simple_read = 0;
        start = 0;
        kernel_dim = 3;
        active_units = 9'b111111111;
        length = 9; // 3x3 kernel
        write_mem1<=1;
        write_mem2<=1;
        simple_write<=1;
        #10
        reset <= 0;
        
       
        
        // Memóriák írása
        write_memory(); // írjuk mem1-be
        #10;
        write_mem1<=0;
        write_mem2<=0;
        simple_write<=0;
        
        start_addr_1[0]<=18'h0000;
        start_addr_1[1]<=18'h0001;
        start_addr_1[2]<=18'h0002;
        
        start_addr_1[3]<=18'h0005;
        start_addr_1[4]<=18'h0006;
        start_addr_1[5]<=18'h0007;
        
        start_addr_1[6]<=18'h000A;
        start_addr_1[7]<=18'h000B;
        start_addr_1[8]<=18'h000C;
        for (integer i=0;i<NUM_UNITS;i=i+1)begin
            start_addr_2[i]<=0;
            simple_write_addr[i]<=0;
        end
        #10
        read_mem1<=1;
        read_mem2<=1;
        simple_read<=1;
        #10
        start<=1;
        wait(done);
        
        
    end

endmodule
