module vector_adder #(
    parameter DATA_WIDTH = 16,
    parameter LENGTH = 16
)(
    input wire clk,                   // Órajel
    input wire reset,                 // Reset jel
    input wire en,                    // Engedélyezés jel
    input wire [DATA_WIDTH-1:0] In_x [0:LENGTH-1],
    input wire [DATA_WIDTH-1:0] In_bias [0:LENGTH-1],  // Tömbként kell deklarálni
    output reg [DATA_WIDTH-1:0] Out [0:LENGTH-1]
);
genvar i;
generate
  
        for (i = 0; i < LENGTH; i = i + 1) begin: gen_blk  
           floating_point_adder #(DATA_WIDTH) dut (
            .clk(clk),
            .reset(reset),
            .en(en),
            .a(In_x[i]),
            .b(In_bias[i]),
            .result(Out[i])
            );
        end
    
    endgenerate
endmodule
