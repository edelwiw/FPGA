module task6_top (
    input wire clock,
    input wire a, b,
    output q, 
    output reg state
);

assign q = a ^ b ^ state;

always @(posedge clock) begin
    state <= b==a ? a : state;
end

endmodule
