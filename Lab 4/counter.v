module counter (
    input clk,
    input rst,
    output reg [9:0] q
);

always @(posedge clk) begin
    q <= rst == 1 ? 0 : q == 999 ? 0 : q + 1;
end

endmodule