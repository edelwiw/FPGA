module part_2_trigger (
    input clk,
    input [7:0] d,
    output reg [7:0] q
);

always @(negedge clk) begin
    q <= d;
end

endmodule