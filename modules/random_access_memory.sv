module random_access_memory (
    input  wire        clk,
    input  wire        write_block,
    input  wire        read_block,
    input  wire        read_matrix,
    input  wire        read_vector,
    input  wire [15:0]  matrix_M,
    input  wire [15:0]  matrix_N,
    input  wire [15:0]  vector_L,
    input  wire [15:0] address_block,
    input  wire [15:0] address_matrix,
    input  wire [15:0] address_vector,
    input  wire [15:0] data_in,
    output reg  [15:0] data_out,
    output reg  [15:0] matrix_out [0:15][0:15],
    output reg  [15:0] vector_out [0:15] 
);

logic [15:0] ram_block [0:2047];
logic [15:0]i;
logic [15:0]j;
always @(posedge clk) begin
    if (write_block) begin
        ram_block[address_block] <= data_in;
    end 
    else if (read_block && ~read_matrix) begin
        data_out <= ram_block[address_block];
    end 
    else if (read_matrix) begin
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
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
    if (read_vector)begin
        for (i=0 ;i<16;i=i+1)begin
            if(i<vector_L)
                vector_out[i]<=ram_block[address_vector+i];
             else
                vector_out[i]<=0;
        
        end
    
    end
    if (read_vector)begin
        for (i=0 ;i<16;i=i+1)begin
            if(i<vector_L)
                vector_out[i]<=ram_block[address_vector+i];
             else
                vector_out[i]<=0;
        
        end
    
    end
    
end

endmodule