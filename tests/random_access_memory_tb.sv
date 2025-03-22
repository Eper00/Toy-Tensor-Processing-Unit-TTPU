module tb_random_access_memory;
  
  reg clk;
  reg read_file;
  reg read_block;
  reg read_matrix;
  reg read_vector;
  reg [5:0] matrix_M;
  reg [5:0] matrix_N;
  
  reg [19:0] file_size;
  reg [19:0] address_block;
  reg [19:0] address_matrix;
  wire [15:0] data_out;
  
  wire [15:0] matrix_out [0:32-1][0:32-1];
  
  // RAM modul példányosítása
  random_access_memory uut (
      .clk(clk),
      .write_block(1'b0), // Nem írunk, csak olvasunk fájlból
      .read_block(read_block),
      .read_file(read_file),
      .read_matrix(read_matrix),
      .matrix_M(matrix_M),
      .matrix_N(matrix_N),
      .file_size(file_size),
      .address_block(address_block),
      .address_matrix(address_matrix),
      .data_in(16'b0),
      .data_out(data_out),
      .matrix_out(matrix_out)
  );

  // Órajel generálása (100 MHz = 10 ns periódus)
  always #5 clk = ~clk;

  initial begin
      read_block=0;
      clk = 0;
      read_file = 0;
      read_matrix = 0;
      read_file = 0;
      read_vector = 0;
      file_size = 1024;  // Pl. 1024 bájtot olvasunk
      address_block=5;
      address_matrix=0;
      matrix_M=2;
      matrix_N=2;
      #10;
      read_file=1;
      #10
      read_file=0;
      read_matrix=1;
      read_block=1;
      #10;
      $finish;
  end

endmodule
