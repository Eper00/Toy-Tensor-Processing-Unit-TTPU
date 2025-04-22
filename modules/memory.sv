module memory_unit #(
    parameter DATA_WIDTH = 16,              // A memória elemeinek szélessége
    parameter IMAGE_WIDTH = 8,              // A teljes memória szélessége (sorok)
    parameter IMAGE_HEIGHT = 8,
    parameter NUM_UNITS = 2             // A teljes memória magassága (oszlopok)
)(
    input  logic clk,
    input  logic reset,
    input  logic step,  
    input  logic en,                     
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] start_addr, // Kezdőcím a memóriában
    input  logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim, 
    
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out, 
    output logic en_out
);

    logic [0:IMAGE_WIDTH*IMAGE_HEIGHT-1][DATA_WIDTH-1:0] image_mem;
    reg [NUM_UNITS-1:0][(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] adress;
    reg [(IMAGE_WIDTH)-1:0] step_counter_cloumn;
    reg [(IMAGE_HEIGHT)-1:0] step_counter_row;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
        for (integer i=0 ;i<NUM_UNITS;i=i+1)begin
            adress[i]<=start_addr[i];
          end
          en_out<=0;
          step_counter_cloumn<=1;  
          step_counter_row<=1;
        end else if (en) begin
            en_out<=1;
               for (integer i=0 ;i<NUM_UNITS;i=i+1)begin
                    out[i]=image_mem[adress[i]];
                end
                if (step)begin
                    if (step_counter_cloumn == kernel_dim)begin
                    for (integer i=0 ;i<NUM_UNITS;i=i+1)begin
                        adress[i]<=adress[i]+IMAGE_WIDTH-kernel_dim;
                    end
                        step_counter_row<=step_counter_row+1;
                        step_counter_cloumn<=1;                    
                    end else begin
                        if (step_counter_row>kernel_dim)begin
                            for (integer i=0 ;i<NUM_UNITS;i=i+1)begin
                                adress[i]<=adress[i];
                            end
                            en_out<=0;
                        end
                        else begin
                        for (integer i=0 ;i<NUM_UNITS;i=i+1)begin
                            adress[i]<=adress[i]+1;
                         end
                            step_counter_cloumn<=step_counter_cloumn+1;
                        end                    
                    end
                    
                end        
            end
        end



endmodule