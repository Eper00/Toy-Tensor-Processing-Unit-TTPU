module vector_adder #(
    parameter DATA_WIDTH = 16,
    parameter NUM_UNITS = 64
)(
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic [NUM_UNITS-1:0] active_units,  // Aktív elemek
    input  logic [DATA_WIDTH-1:0] In_x [0:NUM_UNITS-1],  // Bemeneti vektorok
    input  logic [DATA_WIDTH-1:0] In_bias [0:NUM_UNITS-1],  // Bemeneti bias
    output logic [DATA_WIDTH-1:0] Out [0:NUM_UNITS-1],  // Kimeneti vektor
    output logic ready
);

    // Paraméterek a vezérléshez
    localparam IDLE      = 4'd0;
    localparam ADD_1     = 4'd1;
    localparam ADD_2     = 4'd2;
    localparam ADD_3     = 4'd3;
    localparam ADD_4     = 4'd4;
    localparam DONE      = 4'd5;
    
    // Regiszterek a vezérléshez és az adatokhoz
    reg [3:0] state;
    reg [DATA_WIDTH-1:0] Result [0:NUM_UNITS-1];  // Eredmények tárolása
    wire [DATA_WIDTH-1:0] add_out [0:NUM_UNITS-1];  // Az adderek kimenetei
    
    // Feldolgozó egységek instanciálása
    genvar i;
    generate
        for (i = 0; i < NUM_UNITS; i++) begin : dot_unit_array
            floating_point_adder adder (
                .clk(clk),
                .reset(reset),
                .en(active_units[i]),
                .a(active_units[i] ? In_x[i] : 16'b0),
                .b(active_units[i] ? In_bias[i] : 16'b0),
                .result(add_out[i])
            );
        end
    endgenerate



   always @(posedge clk or posedge reset) begin
       if (reset) begin
                state <= IDLE;
                ready <= 0;
                 for (int i = 0; i < NUM_UNITS; i++) begin
                    Out[i] <= add_out[i]; 
                 end
          end else begin
                case (state)
                    IDLE: begin
                        if (start)begin
                            state <= ADD_1;
                            end
                         else begin
                           state <= IDLE;
                           end
                    end
        
                    ADD_1: begin
                        // Az első addereket engedélyezzük
                        state <= ADD_2;
                    end
                    
                    ADD_2: begin
                        // A következő adderek engedélyezése
                        state <= ADD_3;
                    end
        
                    ADD_3: begin
                        // Tovább folytatjuk az adderekkel
                        state <= ADD_4;
                    end
                    
                    ADD_4: begin
                        state <= DONE;
                    end
        
                    DONE: begin
                        // Kimeneti vektorok frissítése
                        for (int i = 0; i < NUM_UNITS; i++) begin
                            if (active_units[i]) begin
                                Out[i] <= add_out[i];  // Kimeneti vektor
                            end else begin
                                Out[i] <= 0;
                            end
                        end
                        ready <= 1;  // Jelzünk, hogy a művelet befejeződött
                        state <= IDLE;  // Ha nem kérnek új műveletet, álljunk vissza IDLE-ba
                    end
                
                endcase
        end
    end

endmodule
