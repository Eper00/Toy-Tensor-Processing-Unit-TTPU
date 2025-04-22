module dot_product_multiplication_unit #(
    parameter DATA_WIDTH = 16,
    parameter NUM_UNITS = 4,
    parameter IMAGE_WIDTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic [NUM_UNITS-1:0] active_units,
    input  logic [($clog2(IMAGE_WIDTH)-1) * ($clog2(IMAGE_WIDTH)-1):0] length,

    input  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] a_in_array,
    input  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] b_in_array,
    input  logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] bias_array,

    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] relu_out,
    output logic done,
    output logic array_done
);

    typedef enum logic [2:0] {
        IDLE,
        SYSTOLIC_RUN,
        WAIT_SYSTOLIC_DONE,
        START_ADDER,
        WAIT_ADDER_DONE,
        DONE
    } state_t;

    state_t state, next_state;

    // Interconnect
    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] systolic_out;
    logic [NUM_UNITS-1:0] systolic_ready;

    logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] adder_out;
    logic adder_ready;

    logic vector_start;
    logic systolic_start_pulse;

    logic [$clog2(NUM_UNITS+1)-1:0] array_done_count;

    // Systolic array
    systolic_array #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) sa (
        .clk(clk),
        .reset(reset),
        .start(systolic_start_pulse),
        .active_units(active_units),
        .a_in_array(a_in_array),
        .b_in_array(b_in_array),
        .result_array(systolic_out),
        .ready_array(systolic_ready)
    );

    // Vector adder
    vector_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) adder (
        .clk(clk),
        .reset(reset),
        .start(vector_start),
        .active_units(active_units),
        .In_x(systolic_out),
        .In_bias(bias_array),
        .Out(adder_out),
        .ready(adder_ready)
    );

    // ReLU
    ReLu #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_UNITS(NUM_UNITS)
    ) relu (
        .clk(clk),
        .reset(reset),
        .en(adder_ready),
        .In(adder_out),
        .Out(relu_out)
    );

    // Egy ciklusos impulzus a systolic array újraindítására
    assign systolic_start_pulse = (state == SYSTOLIC_RUN);

    // array_done jel
    assign array_done = systolic_ready;
    assign done = adder_ready;

    // array_done_count növelése
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            array_done_count <= 0;
        else if (array_done && state == WAIT_SYSTOLIC_DONE)
            array_done_count <= array_done_count + 1;
    end

    // Állapotgép
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        // Alapértelmezett értékadás minden ciklusra
        next_state = state;
        vector_start = 0;

        case (state)
            IDLE: begin
                if (start)
                    next_state = SYSTOLIC_RUN;
            end

            SYSTOLIC_RUN: begin
                next_state = WAIT_SYSTOLIC_DONE;
            end

            WAIT_SYSTOLIC_DONE: begin
                if (array_done) begin
                    if (array_done_count + 1 < length)
                        next_state = SYSTOLIC_RUN;
                    else
                        next_state = START_ADDER;
                end
            end

            START_ADDER: begin
                vector_start = 1;
                next_state = WAIT_ADDER_DONE;
            end

            WAIT_ADDER_DONE: begin
                if (adder_ready)
                    next_state = DONE;
            end

            DONE: begin
                // Explicit maradás, de biztosítjuk, hogy minden változó stabil marad
                vector_start = 0;
                next_state = DONE;
            end

            default: begin
                // Hibás állapot elkerülése érdekében alapállapotba vissza
                next_state = IDLE;
                vector_start = 0;
            end
        endcase
    end

    // A bemenetek frissítése, amikor a systolic array kész van
   
endmodule
