module ReLu #(
    parameter DATA_WIDTH = 16,
    parameter NUM_UNITS = 16
)(
    input wire clk,                   // Órajel
    input wire reset,                 // Reset jel
    input wire en,                    // Engedélyezés jel
    input wire [NUM_UNITS-1:0][DATA_WIDTH-1:0] In,  
    output logic [NUM_UNITS-1:0][DATA_WIDTH-1:0] Out  
);

always @(posedge clk or posedge reset) begin  // Mindig a clk vagy a reset pozitív élére reagáljon
    if (reset) begin
        integer i;
        for (i = 0; i < NUM_UNITS; i = i + 1) begin
            Out[i] <= 0;   // Minden kimenetet nullázunk
        end
    end else if (en) begin
        integer i;
        for (i = 0; i < NUM_UNITS; i = i + 1) begin
            if (!In[i][DATA_WIDTH-1]) begin  // Ha a legfelső bit 0 (pozitív szám)
                Out[i] <= In[i];  
            end else begin
                Out[i] <= 0;
            end
        end
    end
end

endmodule
