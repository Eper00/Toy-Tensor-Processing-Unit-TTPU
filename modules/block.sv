module processing_unit (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [15:0] P,
    output reg ready
);

    reg [3:0] state;

localparam IDLE      = 4'd0;
localparam MULT_1    = 4'd1;
localparam MULT_2    = 4'd2;
localparam MULT_3    = 4'd3;
localparam SAVE_MULT = 4'd4;
localparam ADD_1     = 4'd5;
localparam ADD_2     = 4'd6;
localparam ADD_3     = 4'd7;
localparam ADD_4     = 4'd8;
localparam ADD_5     = 4'd9;
localparam ADD_6     = 4'd10;
localparam ADD_7     = 4'd11;   // ÚJ állapot
localparam DONE      = 4'd12;



    reg [15:0] mult_result;
    reg [15:0] add_result;

    wire [15:0] mult_out;
    wire [15:0] add_out;

    reg en1, en2;

    floating_point_multiplayer multiplier (
        .clk(clk),
        .reset(reset),
        .en(en1),
        .a(a),
        .b(b),
        .result(mult_out)
    );

    floating_point_adder adder (
        .clk(clk),
        .reset(reset),
        .en(en2),
        .a(mult_result),
        .b(P),
        .result(add_out)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            P <= 16'd0;
            mult_result <= 16'd0;
            add_result <= 16'd0;
            ready <= 0;
            en1 <= 0;
            en2 <= 0;
        end else begin
            // Alapértelmezetten letiltjuk az engedélyezőket
            en1 <= 0;
            en2 <= 0;
            ready <= 0;

            case (state)
                IDLE: begin
                    if (start) begin
                        en1 <= 1;
                        state <= MULT_1;
                    end
                end

                MULT_1: begin
                    en1 <= 1;
                    state <= MULT_2;
                end

                MULT_2: begin
                    en1 <= 1;
                    state <= MULT_3;
                end

               MULT_3: begin
                    en1 <= 0;
                    state <= SAVE_MULT;
                end
                
                SAVE_MULT: begin
                    mult_result <= mult_out;
                    en2 <= 1;
                    state <= ADD_1;
                end
                
                ADD_1: begin
                    en2 <= 1;
                    state <= ADD_2;
                end
                
                ADD_2: begin
                    en2 <= 1;
                    state <= ADD_3;
                end
                
                ADD_3: begin
                    en2 <= 1;
                    state <= ADD_4;
                end
                
                ADD_4: begin
                    en2 <= 1;
                    state <= ADD_5;
                end
                
                ADD_5: begin
                    en2 <= 1;
                    state <= ADD_6;
                end
                
                ADD_6: begin
                    en2 <= 1;
                    state <= ADD_7;
                end
                ADD_7: begin
                    en2 <= 1;
                    state <= DONE;
                end
                
                DONE: begin
                en2 <= 0;
                    if (!start)
                       add_result <= add_out;
                       P<= add_out;
                       ready <= 1;
                       state <= IDLE;
                end
                
                
                endcase 
        end
    end
endmodule
