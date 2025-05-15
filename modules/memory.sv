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
    input logic read,
    input logic write,
    input logic   [NUM_UNITS-1:0][DATA_WIDTH-1:0] data_in,
    input  logic [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] addres_in, // Kezdőcím a memóriában
    input  logic [$clog2(IMAGE_WIDTH)-1:0] kernel_dim, 
    
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] out, 
    output logic en_out
);

    logic [0:IMAGE_WIDTH*IMAGE_HEIGHT-1][DATA_WIDTH-1:0] image_mem;
    reg [NUM_UNITS-1:0][$clog2(IMAGE_WIDTH*IMAGE_HEIGHT)-1:0] adress;
    reg [(IMAGE_WIDTH)-1:0] step_counter_cloumn;
    reg [(IMAGE_HEIGHT)-1:0] step_counter_row;
    
        logic read_started; // új regiszter a kezdet detektálásához

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < NUM_UNITS; i = i + 1) begin
                adress[i] <= 0;
            end
            en_out <= 0;
            step_counter_cloumn <= 1;  
            step_counter_row <= 1;
            read_started <= 0;
        end else begin
            if (en && read) begin
                en_out <= 1;
                if (!read_started) begin
                    // Első olvasás, betöltjük a kezdő címeket
                    for (integer i = 0; i < NUM_UNITS; i = i + 1) begin
                        adress[i] <= addres_in[i];
                        out[i] <= image_mem[addres_in[i]]; // közvetlen kiolvasás is az első ciklusban
                    end
                    read_started <= 1;
                end else begin
                    // Továbblépés a megszokott módon
                    for (integer i = 0; i < NUM_UNITS; i = i + 1) begin
                        out[i] <= image_mem[adress[i]];
                    end

                    if (step) begin
                        if (step_counter_cloumn == kernel_dim) begin
                            for (integer i = 0; i < NUM_UNITS; i = i + 1) begin
                                adress[i] <= adress[i] + IMAGE_WIDTH - kernel_dim+1;
                            end
                            step_counter_row <= step_counter_row + 1;
                            step_counter_cloumn <= 1;
                        end else begin
                            if (step_counter_row > kernel_dim) begin
                                en_out <= 0;
                            end else begin
                                for (integer i = 0; i < NUM_UNITS; i = i + 1) begin
                                    adress[i] <= adress[i] + 1;
                                end
                                step_counter_cloumn <= step_counter_cloumn + 1;
                            end
                        end
                    end
                end
            end else begin
                read_started <= 0; // ha nem olvasunk, visszaállítjuk a flaget
            end

            if (en && write) begin
                for (integer i = 0; i < NUM_UNITS; i = i + 1) begin
                    image_mem[addres_in[i]] <= data_in[i];
                end
            end
        end
    end


endmodule