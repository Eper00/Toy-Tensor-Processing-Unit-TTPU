module random_access_memory (
    input  wire        clk,
    input  wire        write_block,
    input  wire        read_block,
    input  wire        read_file,
    input  wire        read_matrix,
    input  wire [5:0]  matrix_M,
    input  wire [5:0]  matrix_N,
    input  wire [19:0] file_size,
    input  wire [19:0] address_block,
    input  wire [19:0] address_matrix,
    input  wire [15:0] data_in,
    output reg  [15:0] data_out,
    output reg  [15:0] matrix_out [0:31][0:31] // 32 helyett 31, hogy indexelés helyes legyen
);

integer fd;
integer code;
logic [15:0] ram_block [0:1048575];

always @(posedge clk) begin
    if (write_block) begin
        ram_block[address_block] <= data_in;
    end 
    else if (read_block && ~read_matrix) begin
        data_out <= ram_block[address_block];
    end 
    else if (read_file) begin
        fd = $fopen("C:/VivadoWorkspace/Tensor Processing Unit/data.bin", "r");
        
        if (fd == 0) begin
            $display("Error: Could not open file.");
        end
        else begin
            // Read data from the file into memory array
            code = $fread(ram_block, fd); // `$fread` helyes használata
            
            if (code == 0) begin
                $display("Error: Could not read data.");
            end 
            else begin
                $display("Read %0d bytes of data.", code);
            end

            $fclose(fd);
        end
    end 
    else if (read_matrix) begin
        for (integer i = 0; i < 32; i = i + 1) begin
            for (integer j = 0; j < 32; j = j + 1) begin
                if (i < matrix_M) begin
                    if (j < matrix_N)
                        matrix_out[i][j] <= ram_block[address_matrix + matrix_M * i + j];
                    else
                        matrix_out[i][j] <= 0;
                end 
                else begin
                    matrix_out[i][j] <= 0;
                end
            end
        end
    end

    if (read_block) begin
        data_out <= ram_block[address_block];
    end
end

endmodule
