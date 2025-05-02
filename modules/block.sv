module processing_unit (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [15:0] P,
    output reg ready
);

    typedef enum logic [2:0] {
        IDLE,
        MULT_START,
        MULT_WAIT,
        ADD_START,
        ADD_WAIT,
        RESET_INNER,
        DONE
    } state_t;

    state_t state, next_state;

    reg [15:0] mult_result;

    reg en1, en2;
    reg rst_multiplier, rst_adder;

    wire [15:0] mult_out;
    wire [15:0] add_out;
    wire mult_ready;
    wire add_ready;

    floating_point_multiplayer multiplier (
        .clk(clk),
        .reset(rst_multiplier),
        .en(en1),
        .a(a),
        .b(b),
        .result(mult_out),
        .ready(mult_ready)
    );

    floating_point_adder adder (
        .clk(clk),
        .reset(rst_adder),
        .en(en2),
        .a(mult_result),
        .b(P),
        .result(add_out),
        .ready(add_ready)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            ready <= 0;
            P <= 16'd0;
            en1 <= 0;
            en2 <= 0;
            rst_multiplier <= 1;
            rst_adder <= 1;
        end else begin
            state <= next_state;

            // alapértelmezés minden ciklusban
            en1 <= 0;
            en2 <= 0;
            rst_multiplier <= 0;
            rst_adder <= 0;
            ready <= 0;

            case (state)
                IDLE: begin
                    if (start) begin
                        en1 <= 1;
                    end
                end

                MULT_START: begin
                    en1 <= 1;
                end

                MULT_WAIT: begin
                    en1 <= 1;
                    if (mult_ready) begin
                        mult_result <= mult_out;
                        en2 <= 1;
                        en1 <= 0;
                    end
                end

                ADD_START: begin
                    en2 <= 1;
                end

                ADD_WAIT: begin
                    en2 <= 1;
                    if (add_ready) begin
                        P <= add_out;
                         en2 <= 0;
                    end
                end

                RESET_INNER: begin
                    // Reseteljük a belső egységeket egy ciklusra
                    rst_multiplier <= 1;
                    rst_adder <= 1;
                end

                DONE: begin
                    ready <= 1;  // eredmény kész, tartjuk a P-t
                end
            endcase
        end
    end

  always_comb begin
    next_state = state;

    case (state)
        IDLE: begin
            if (start)
                next_state = MULT_START;
        end

        MULT_START: begin
            next_state = MULT_WAIT;
        end

        MULT_WAIT: begin
            if (mult_ready)
                next_state = ADD_START;
        end

        ADD_START: begin
            next_state = ADD_WAIT;
        end

        ADD_WAIT: begin
            if (add_ready)
                next_state = RESET_INNER;
        end

        RESET_INNER: begin
            next_state = DONE;
        end

        DONE: begin
            if (!start)
                next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end


endmodule
