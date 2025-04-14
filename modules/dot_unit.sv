module dot_unit #(
    parameter WIDTH = 16,
    parameter MAX_LENGTH = 64  // maximum bemeneti párok száma
)(
    input  logic clk,
    input  logic reset,
    input  logic start,

    input  logic [WIDTH-1:0] a_in,
    input  logic [WIDTH-1:0] b_in,
    input  logic [$clog2(MAX_LENGTH)-1:0] length,

    output logic [WIDTH-1:0] result,
    output logic done
);

    logic [$clog2(MAX_LENGTH)-1:0] counter;

    // állapotgép
    typedef enum logic [1:0] {
        IDLE,
        RUNNING,
        WAIT_READY,
        DONE
    } state_t;

    state_t state, next_state;

    // feldolgozó unit (egy pipelined multiplier pl.)
    logic en;
    logic [WIDTH-1:0] pu_a, pu_b;
    wire  [WIDTH-1:0] pu_P;
    wire pu_ready;

    processing_unit pu (
        .clk(clk),
        .reset(reset),
        .start(en),
        .a(pu_a),
        .b(pu_b),
        .P(pu_P),
        .ready(pu_ready)
    );

    // Állapotgép logika
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            counter <= 0;
            result <= 0;
            done <= 0;
            en <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    if (start) begin
                        counter <= 0;
                        done <= 0;
                        en <= 1;
                        pu_a <= a_in;
                        pu_b <= b_in;
                    end
                end

                RUNNING: begin
                    en <= 0;
                    if (pu_ready) begin
                        counter <= counter + 1;
                        if (counter + 1 < length) begin
                            en <= 1;
                            pu_a <= a_in;
                            pu_b <= b_in;
                        end
                    end
                end

                DONE: begin
                    result <= pu_P;
                    done <= 1;
                end
            endcase
        end
    end

    // Következő állapot
    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (start) next_state = RUNNING;
            RUNNING: if (pu_ready && (counter + 1 == length)) next_state = DONE;
            WAIT_READY: next_state = WAIT_READY;
            DONE: if (!start) next_state = IDLE;
        endcase
    end

endmodule
