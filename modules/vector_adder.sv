module vector_adder #(
    parameter DATA_WIDTH = 16,
    parameter NUM_UNITS = 4
)(
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic [NUM_UNITS-1:0] active_units,
    input  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] In_x,
    input  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] In_bias,
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] Out,
    output logic ready
);
    // Állapotok
    typedef enum logic [2:0] {
        IDLE,
        START_ADD,
        WAIT_READY,
        HOLD,
        DONE
    } state_t;

    state_t state, next_state;
    
    logic [DATA_WIDTH-1:0] result [0:NUM_UNITS-1];
    logic [NUM_UNITS-1:0] adder_ready;
    logic [DATA_WIDTH-1:0] adder_result [0:NUM_UNITS-1];
    reg en1;
    // Adderek példányosítása
    genvar i;
    generate
        for (i = 0; i < NUM_UNITS; i++) begin : adders
            floating_point_adder adder (
                .clk(clk),
                .reset( ~en1 || reset),
                .en(active_units[i] && en1),
                .a(In_x[i]),
                .b(In_bias[i]),
                .result(adder_result[i]),
                .ready(adder_ready[i])
            );
        end
    endgenerate

    // Állapotgép szekvenciális logikája
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            ready <= 0;
            
            for (int i = 0; i < NUM_UNITS; i++) begin
                Out[i] <= 0;
            end
        end else begin
            state <= next_state;

            if (state == DONE) begin
                ready <= 1;
            end else begin
                ready <= 0;
            end

            if (state == HOLD) begin
                for (int i = 0; i < NUM_UNITS; i++) begin
                    if (active_units[i]) begin
                        Out[i] <= result[i];  // tartjuk az eredményt
                    end
                end
            end
        end
    end

    // Következő állapot logika
    always_comb begin
        next_state = state;
       

        case (state)
            IDLE: begin
            en1=0;
             for (int i = 0; i < NUM_UNITS; i++) begin
                result[i] = 0;
            end
                if (start) begin
                    next_state = START_ADD;
                end
            end

            START_ADD: begin
                en1=1;
                next_state = WAIT_READY;
            end

            WAIT_READY: begin
            en1=1;
                if (&(adder_ready | ~active_units)) begin
                    // minden aktív adder készen van
                    for (int i = 0; i < NUM_UNITS; i++) begin
                        if (active_units[i]) begin
                            result[i] = adder_result[i];
                        end
                    end
                    next_state = HOLD;
                end
                
            end

            HOLD: begin
            en1=1;
                // tartjuk az értékeket, egy ciklusig
                next_state = DONE;
            end

            DONE: begin
            en1=0;
                if (!start) begin
                    next_state = IDLE;
                end
            end
            default: begin
            // Hiba esetére, default viselkedés: menjünk vissza IDLE állapotba
            next_state = IDLE;
            en1 = 0;
            
        end
        endcase
    end

endmodule
