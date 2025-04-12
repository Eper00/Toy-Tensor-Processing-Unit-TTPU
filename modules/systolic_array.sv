module systolic_array (
    
    input wire clk,                 
    input wire reset,                
    input wire en,
    input wire [5:0] matrix_N,                   
    input wire [16-1:0] a [0:15], 
    input wire [16-1:0] b [0:15], 
    output reg [16-1:0] P [0:15],
    output reg ready  
);

// Regiszterek az adatok tárolására
reg [16-1:0] A_reg [0:15];
reg [16-1:0] B_reg [0:15];
reg [5:0]l;

// PU modulok deklarálása minden egyes elemhez
genvar i, j;
generate
    for (i = 0; i < 16; i = i + 1) begin: row
            processing_unit  pu_inst (
                .clk(clk),
                .reset(reset),
                .en(en),
                .a(A_reg[i]),  // A bemeneti adat
                .b(B_reg[i]),  // B bemeneti adat
                .P(P[i])       // Kimeneti adat
            );
    end
endgenerate

// Fő működési logika
always @(posedge clk or posedge reset) begin
   
    if (reset) begin
        // Reseteljük az A_reg és B_reg mátrixokat
        for (integer x = 0; x < 16; x = x + 1) begin 
           A_reg[x] <= 0;
           B_reg[x] <= 0;
           l<=0;
           ready<=0;
            
        end
    end else if (en && ~ready) begin
        for (integer x=0;x<16;x=x+1)begin
            A_reg[x] <= a[x];
        end
        for (integer x=16-1;x>0;x=x-1)begin
            B_reg[x] <= B_reg[x-1];
            if (l<matrix_N)begin
            B_reg[0] <=b[l];
            end else begin 
            B_reg[0] <=0;
            end
        
        end
        l<=l+1;
        
        if (l==2*matrix_N+1)begin
            ready<=1;
        
        end
    end
end

endmodule